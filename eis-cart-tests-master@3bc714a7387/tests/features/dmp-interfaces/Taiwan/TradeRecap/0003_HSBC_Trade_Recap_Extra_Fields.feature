#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--1787168545
#https://jira.intranet.asia/browse/TOM-4566
#https://jira.intranet.asia/browse/TOM-4664 - Publish bloomberg Ticker, Set ESI_INTEREST_WHT to empty if Equity, Fund. Add a column of TRD_YIELD towards the end of the trade file. For both SSB and HSBC.
#https://jira.intranet.asia/browse/TOM-4691 - Store UDF for TW CP Intr Tax and add it in TRD_COMMISSION & NET_AMOUNT
#https://jira.intranet.asia/browse/TOM-4694 - Exclude Cancelled Trades
#https://jira.intranet.asia/browse/TOM-4716 - Remove Custodian FX | Change FUTURE Ticker
#https://jira.intranet.asia/browse/TOM-4722 - Include Onshore CIS BUY executed Trades
#https://jira.intranet.asia/browse/TOM-4762 - Filter >=T date trades for B2 | Pull full history
#https://jira.intranet.asia/browse/TOM-5048 -  Amend logic for Custodian FX and include Ticker for all Futures - For HSBC, trades starting with C_ needs to be excluded. For HSBC & SSB, the Alladin ticker to be published in case of FUTURE secgroup and any sectype(FUTURE/*)
#                                              Trades loaded - '3205-5048_CPTY' - having counterparty starting with 'C_' - Expected not be picked in publishing
#                                                             '3205-5048_CPTY_CUSTTRADER' - having counterparty starting with 'C_' and TRD_TRADER as 'CUSTTRADER' - Expected not be picked in publishing
#                                                             '3205-4716_5048_FUTUREANY_CPTY_CUSTTRD' - INVNUM changed from '-4716_index' to '-4716_5048_FUTUREANY_CPTY_CUSTTRD' & security changed from FUTURE/INDEX to FUTURE/FIN - Expected to be picked as TRDTRADER!=CUSTTRADER and TRD_COUNTERPARTY!=C_% with Alladin ticker value published
#https://jira.intranet.asia/browse/TOM-5072 - Mapping changes for TRD_REG_DATE field in HSBC Trade recap outbound file
#https://jira.pruconnect.net/browse/EISDEV-4567 - Mapping Changes for TRD_FIFO_TYPE field in HSBC Trade recap outbound file


@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4566 @tom_4602 @trade_recap @tom_4664 @trade_recap_additional_fields_hsbc @tom_4691 @tom_4694 @tom_4716 @tom_4722 @tom_4762 @tom_5048 @tom_5072 @eisdev_4567
Feature: Test Publishing of additional fields of HSBC Trade Recap data for batch 1 and batch 2

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_tom_4566.sql
    """

    And I execute below query and extract values of "CURR_DATE" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE from dual
     """

    And I execute below query and extract values of "CURR_DATE_MINUS_1" into same variables
     """
     select to_char(max(GREG_DTE),'MM/DD/YYYY') AS CURR_DATE_MINUS_1 from ft_t_cadp where GREG_DTE < trunc(SYSDATE) and end_tms is null and BUS_DTE_IND = 'Y' and cal_id = 'PRPTUAL'
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

    Given I assign "Portfolio_template_TOM_4566.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP1_FRAP_HSBC_TOM_4566.sql
    """

  Scenario: Load Fresh data for Trades (Trade records TRD_ID ='3205-302', '3205-2776_valid_trade_parent, '3205-4716_Cust', '3205-4722', '3205-4762', '3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD')

    Given I assign "CounterParty_TOM_5048.xml" to variable "INPUT_FILENAME2"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID2}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

    And I assign "003_tradefile_hsbc.xml" to variable "INPUT_FILENAME"
    And I assign "003_tradefile_hsbc_template.xml" to variable "INPUT_TEMPLATENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | TRADE_DATE | DateTimeFormat:M/dd/YYYY |

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
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
      AND TASK_TOT_CNT = 9
      AND TASK_CMPLTD_CNT = 9
      """

  Scenario: Publish trade recap file for HSBC (3 Trade records TRD_ID ='3205-302', '3205-2776_valid_trade_parent', '3205-4722', '3205-4762', '3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD')

    Given I assign "traderecap_hsbc_out_file_B1_4566" to variable "PUBLISHING_FILE_NAME"
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
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722', '3205-4762') AND  END_TMS IS NULL
      )
      """

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'EXECSENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722','3205-4762') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Given I assign "TradeRecapExpected_hsbc_tom_4566_B1_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_hsbc_tom_4566_B1.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      | TRADE_DATE | DateTimeFormat:MM/dd/YYYY |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/TradeRecapExpected_hsbc_tom_4566_B1.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_003traderecap_exceptions.csv" file

  Scenario: Load confirmed trade to verify if it is getting published after Executed trade

    Given I assign "004_tradefile_hsbc.xml" to variable "INPUT_FILENAME"

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

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_out_file_B1_4722" to variable "PUBLISHING_FILE_NAME"
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
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT IN (1,2)
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722','3205-4762') AND  END_TMS IS NULL
      )
      """

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'EXECSENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722','3205-4762') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Given I assign "TradeRecapExpected_hsbc_tom_4722_B1_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_hsbc_tom_4722_B1.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_003traderecap_exceptions.csv" file

  Scenario: Test Publish Trade Recap To HSBC for batch 2 - Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_tom_4566.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_hsbc_out_file" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  #waiting intentionally
    And I pause for 20 seconds

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_4566.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP2_FRAP_HSBC_TOM_4566.sql
    """

  Scenario: Load Fresh data for Trades (Trade records TRD_ID ='3205-302', '3205-2776_valid_trade_parent', '3205-4722','3205-4762' ,'3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD')

    Given I assign "003_tradefile_hsbc.xml" to variable "INPUT_FILENAME"
    And I assign "003_tradefile_hsbc_template.xml" to variable "INPUT_TEMPLATENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | TRADE_DATE | DateTimeFormat:M/dd/YYYY |

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
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
      AND TASK_TOT_CNT = 9
      AND TASK_CMPLTD_CNT = 9
      """

  Scenario: Publish trade recap file for HSBC (3 Trade records TRD_ID ='3205-302', '3205-2776_valid_trade_parent','3205-4722','3205-4762' ,'3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD')

    Given I assign "traderecap_hsbc_out_file_B2_4566" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722','3205-4762') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file
    Given I assign "TradeRecapExpected_hsbc_tom_4566_B2_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_hsbc_tom_4566_B2.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect each record in file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_003traderecap_exceptions.csv" file

  Scenario: Load confirmed trade to verify if it is getting published after Executed trade

    Given I assign "004_tradefile_hsbc.xml" to variable "INPUT_FILENAME"

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

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_out_file_B2_4722" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT IN (1,2)
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722','3205-4762') AND  END_TMS IS NULL
      )
      """

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'EXECSENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3205-302','3205-2776_valid_trade_parent','3205-5048_CPTY','3205-5048_CPTY_CUSTTRADER','3205-4716_5048_FUTUREANY_CPTY_CUSTTRD','3205-4716_Cust','3205-4722','3205-4762') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Given I assign "TradeRecapExpected_hsbc_tom_4722_B2_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_hsbc_tom_4722_B2.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect each record in file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_003traderecap_exceptions.csv" file