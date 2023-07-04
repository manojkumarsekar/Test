#https://jira.intranet.asia/browse/TOM-4297  (Initial ticket)
#https://jira.pruconnect.net/browse/EISDEV-6055 : as part of this ticket, exception id changed from 60001 to 60003
#https://jira.pruconnect.net/browse/EISDEV-6168 : as part of this ticket, exception id changed from 60003 to 60016

@gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4297 @tom_5270 @esidev_6055 @hsbc_ssb_nav @esidev_6168
Feature: Test Load and publish of NAV file from HSBC to BRS

  Verify & remove the data and file if present already
  Execute the workflow to publish the NAV file
  Verify if file got published or not
  Verify data in the published file
  Verify two scenarios ie to check price for porfolio and throw error for PREV_NET_ASSET

  Scenario: TC_1: Initialize and Set up Data

    Given I assign "esi_TW_tradein_hsbc_nav" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NAV" to variable "testdata.path"

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM4297.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    And I execute below query to "Clear data for the given NAV for FT_T_ACCV Table"
    """
    ${testdata.path}/sql/ClearData_NAV_HSBC_BRS.sql
    """

  Scenario: Publish BRS NAV File

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

  Scenario: TC_2: Check the price for PORTFOLIO in NAV outbound file

    Given I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    Given I expect column "PORTFOLIO" value to be "4297SCN1PARENT_USD" where columns values are as below in CSV file "${CSV_FILE}"
      | TRANSACTION             | BUY       |
      | QUANTITY                | 10        |
      | SECURITY.ALADDIN_SEC_ID | BPM2N6WQ5 |

  Scenario: TC_3: Load file to throw error for PREV_NET_ASSET

    Given I assign "HSBC_FILE_THROW_ERROR.csv" to variable "INPUT_FILENAME_1"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}    |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Checking NTEL
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
    WHERE NOTFCN_ID='60016'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='User defined Error thrown! . PREV_NET_ASSET value is not same'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """