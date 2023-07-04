#https://jira.intranet.asia/browse/TOM-4818

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_securities
@dmp_regression_integrationtest
@dmp_taiwan @tom_4818 @trade_recap @eisdev_7114
Feature: Test Publishing of SSB Trade Recap data for batch 1

  Scenario: Load Fresh data for Trades 4818-4818

    Given I assign "Options.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_4818.sql
    """

  Scenario: Setup new account in DMP

    Given I assign "TOM_4818.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP1_FRAP_SSB_4818.sql
    """

  Scenario: Load Fresh data for Trades 4818-4818

    Given I assign "TRD_1_hsbc.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

  Scenario: Publish trade recap file for SSB

    Given I assign "traderecap_ssb_out_file_1_B1_4818" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'SSB'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4818-4818') AND  END_TMS IS NULL
      )
      """

  Scenario: Check the outbound file

    Given I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

#Check if PORTFOLIO CUSIP has value BPM21EWK5 in the outbound
    Given I expect column "CUSIP" value to be "BPM21EWK5" where columns values are as below in CSV file "${CSV_FILE}"
      | FUND                      | 4818     |
      | INVNUM                    | -4818    |
      | PORTFOLIOS_PORTFOLIO_NAME | Test4818 |
      | SM_SEC_GROUP              | OPTION   |
      | SM_SEC_TYPE               | CUROTC   |
      | TRAN_TYPE1                | TRD      |
      | TICKER                    | COJ9P    |
      | TRD_CURRENCY              | JPY      |

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_4818.sql
    """

  Scenario: Load Fresh data for Trades 4818-4818

    Given I assign "TRD_2_hsbc.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

  Scenario: Publish trade recap file for SSB

    Given I assign "traderecap_ssb_out_file_2_B1_4818" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'SSB'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4818-4818') AND  END_TMS IS NULL
      )
      """

  Scenario: Check the outbound file

    Given I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"
#Check if PORTFOLIO CUSIP has value BPM21EWK5 in the outbound
    Given I expect column "CUSIP" value to be "BPM21EWK5" where columns values are as below in CSV file "${CSV_FILE}"
      | FUND                      | 4818     |
      | INVNUM                    | -4818    |
      | PORTFOLIOS_PORTFOLIO_NAME | Test4818 |
      | SM_SEC_GROUP              | OPTION   |
      | SM_SEC_TYPE               | CUROTC   |
      | TRAN_TYPE1                | TRD      |
      | TICKER                    | COJ9P    |
      | TRD_CURRENCY              | TWD      |