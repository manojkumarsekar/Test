#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--2066775069
#https://jira.intranet.asia/browse/TOM-3382
#https://jira.intranet.asia/browse/TOM-4664 - Publish bloomberg Ticker, Set ESI_INTEREST_WHT to empty if Equity, Fund. Add a column of TRD_YIELD towards the end of the trade file. For both SSB and HSBC.
#https://jira.intranet.asia/browse/TOM-4694 - Exclude Cancelled Trades
#https://jira.intranet.asia/browse/TOM-4859 - Round fields to 6 decimal points:  TRD_PRINCIPAL, TRD_ORIG_FACE, TRD_COUPON
#https://jira.intranet.asia/browse/TOM-5072 - Mapping changes for TRD_REG_DATE field in HSBC Trade recap outbound file
#https://jira.pruconnect.net/browse/EISDEV-4567 - Mapping Changes for TRD_FIFO_TYPE field in HSBC Trade recap outbound file
#eisdev-6321: filter trader = itap records
#EISDEV-7110: feature file changed to extract CURR_DATE

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios
@dmp_regression_integrationtest
@dmp_taiwan
@dmp_gs_upgrade
@tom_4899 @tom_3382 @tom_4602 @trade_recap @tom_4664 @trade_recap_hsbc_b1 @tom_4694 @tom_4859 @tom_5072
@eisdev_4567 @eisdev_6321 @eisdev_7110

Feature: Test Publishing of HSBC Trade Recap data for batch 1

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC.sql;
    """

    And I execute below query and extract values of "CURR_DATE" into same variables
    """
    select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE from dual
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_hsbc_out_file" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  #waiting intentionally
    And I pause for 20 seconds

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_3382.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP1_FRAP_HSBC.sql
    """

  Scenario: Load Fresh data for Trades (2 Trade records TRD_ID ='3204-302' and '3204-2776_valid_trade_parent)

    Given I assign "001_tradefile_hsbc.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect workflow is processed in DMP with total record count as "4"

  Scenario: Publish trade recap file for HSBC (2 Trade records TRD_ID ='3204-302' and '3204-2776_valid_trade_parent)

    Given I assign "traderecap_hsbc_out_file_B1_3382_01" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3204-302','3204-2776_valid_trade_parent') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Given I assign "TradeRecapExpected_01_hsbc_b1_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_01_hsbc_b1.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_001traderecap_exceptions.csv" file

  #Scenarios to test filter query checks
  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_hsbc_out_file" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load data for Trades (Existing above 2 records and new 3 records of trades )

    Given I assign "002_tradefile_hsbc.xml" to variable "INPUT_FILENAME"

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
      AND TASK_TOT_CNT = 6
      AND TASK_CMPLTD_CNT = 6
      """

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_out_file_B1_3382_02" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    # First 2 trade records are existing and will get skip as EXST is present for those with status SENT
    # Third Record will get skip as filter query criteria not satisfied - Not attached to Account Group - TWFACAP1
    # Third Record will get skip as filter query criteria not satisfied - Not attached to FUND_ADMINISTRATOR = HSBC TW
    # Fourth Record should get published as it satisfied all filter criteria

  Scenario: Verify trade status

    Then I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3204-401a_AT','3204-402a_AT','3204-403a_AT') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Given I assign "TradeRecapExpected_02_hsbc_b1_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_02_hsbc_b1.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_001traderecap_exceptions.csv" file