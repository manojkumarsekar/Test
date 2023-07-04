#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--2066775069
#https://jira.intranet.asia/browse/TOM-3383
#https://jira.intranet.asia/browse/TOM-4664 - Publish bloomberg Ticker, Set ESI_INTEREST_WHT to empty if Equity, Fund. Add a column of TRD_YIELD towards the end of the trade file. For both SSB and HSBC.
#https://jira.intranet.asia/browse/TOM-4694 - Exclude Cancelled Trades
#EISDEV_4693 : PORTFOLIOS_PORTFOLIO_NAME in the outbound file should display the parent portfolio name based on the hierarchy. eg. Portfolio TD00107_S should have TD00107 in the output
#eisdev-6321: filter trader = itap records. Also updated ACCR to end_date parent relation for reconcillition

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios
@dmp_regression_integrationtest
@dmp_taiwan
@dmp_gs_upgrade
@tom_3383 @trade_recap @tom_4664 @trade_recap_ssb_b2 @tom_4694 @tom_4783 @eisdev_4693 @eisdev_6321
Feature: Test Publish Trade Recap To SSB for batch 2

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST.sql
    """

    And I execute below query and extract values of "CURR_DATE" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE from dual
     """

    And I execute below query and extract values of "CURR_DATE_MINUS_1" into same variables
     """
     select to_char(max(GREG_DTE),'MM/DD/YYYY') AS CURR_DATE_MINUS_1 from ft_t_cadp where GREG_DTE < trunc(SYSDATE) and end_tms is null and BUS_DTE_IND = 'Y' and cal_id = 'PRPTUAL'
     """

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_3383.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP2_FRAP_SSB.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_ssb_out_file_b2_01" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load Fresh data for Trades (2 Trade records TRD_ID ='3204-302' and '3204-2776_valid_trade_parent)

    Given I assign "001_tradefile.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect workflow is processed in DMP with total record count as "5"

  Scenario: Publish trade recap file for SSB (2 Trade records TRD_ID ='3204-302' and '3204-2776_valid_trade_parent)

    Given I assign "traderecap_ssb_out_file_b2_01" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'SSB'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3204-302','3204-2776_valid_trade_parent') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap SSB file

    Given I assign "TradeRecapExpected_01_ssb_b2_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_01_ssb_b2.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/TradeRecapExpected_01_ssb_b2.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_001traderecap_exceptions.csv" file


#Scenarios to test filter query checks
  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_ssb_out_file_b2_02" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load data for Trades (Existing above 2 records and new 3 records of trades )

    Given I assign "002_tradefile.xml" to variable "INPUT_FILENAME"

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

  Scenario: Publish trade recap file for SSB

    Given I assign "traderecap_ssb_out_file_b2_02" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
    # First 2 trade records are existing and will get skip as EXST is present for those with status SENT
    # Third Record will get skip as filter query criteria not satisfied - Not attached to Account Group - TWFACAP1
    # Third Record will get skip as filter query criteria not satisfied - Not attached to FUND_ADMINISTRATOR = SSB TW
    # Fourth Record should get published as it satisfied all filter criteria
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'SSB'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3204-401a_AT','3204-402a_AT','3204-403a_AT') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap SSB file
    Given I assign "TradeRecapExpected_02_ssb_b2_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_02_ssb_b2.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |
    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/TradeRecapExpected_02_ssb_b2.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_001traderecap_exceptions.csv" file