# =================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 18/11/2019      EISDEV-5286    R3.RPT-CF Report
# 13/12/2019      EISDEV-5448    Regression issue fix
# Requirement https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOM&title=FIN-01+-+Net+Flows+legacy+system
# =================================================================================

@dw_interface_transactions @dw_interface_netflows
@dmp_dw_regression
@eisdev_5286
Feature: Month-end report - CF Report. Refer Issuer currency instead of Settlement currency to calculate In and Outflow

  Reconcile Transaction report to ensure Issuer currency based calculation

  Scenario: Setup variables and replace batch IDs (to avoid deletions)

    # Some static data MDXs use a regex to extract date, thus additional numeric character (e.g. TC01) are avoided

    Given I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Transaction" to variable "testdata.path"
    And I assign "ESIPME_TRN_20191031_1200553.out" to variable "TRAN_INPUT_FILENAME"
    And I assign "/dmp/out/eis/netflows" to variable "PUBLISHING_DIR"
    And I assign "CF_SG" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRAN_INPUT_FILENAME} |

    And I execute below query to "Clear data from warehouse tables"
    """
    ${testdata.path}/sql/003_ClearDown.sql
    """

  Scenario: Load securities

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                |
      | FILE_PATTERN  | ${TRAN_INPUT_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_BNP_EOM_TRANSACTION_T+1 |

    # Validation: records in ft_t_extr
    Then I expect value of column "TRAN_COUNT" in the below SQL query equals to "2":
        """
        SELECT Count(1) AS TRAN_COUNT
        FROM   ft_t_extr extr
        WHERE  trd_curr_cde = 'IDR'
               AND trd_id IN ( 'C1049056A', 'C1054913A' )
               AND end_tms IS NULL
        """

    # Validation: records in ft_t_etam
    Then I expect value of column "SUM_CAMT" in the below SQL query equals to "-11151.74":
        """
        SELECT Sum(ETAM.net_settle_camt) AS SUM_CAMT
        FROM   ft_t_extr EXTR
               INNER JOIN ft_t_etam ETAM
                       ON ETAM.exec_trd_id = EXTR.exec_trd_id
        WHERE  ETAM.extn_curr_typ = 'LOCAL'
               AND EXTR.trd_curr_cde = 'IDR'
               AND EXTR.trd_id IN ( 'C1049056A', 'C1054913A' )
               AND EXTR.end_tms IS NULL
        """

  Scenario: Publish Transactions

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    And  I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_NETFLOWS_SUB              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I expect each record in file "${testdata.path}/testdata/Netflows_CF_SG.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/003_1_1_exceptions_${recon.timestamp}.csv" file
