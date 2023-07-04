#https://jira.intranet.asia/browse/TOM-4468
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--718988737
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=58892753
#eisdev-6321: filter trader = itap records

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_securities @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan @tom_4468 @trade_recap @tom_4468_B1 @eisdev_6321
Feature: This feature file is to test Trade Recap FX Forward data published with Batch 1.
  Trade Recap to HSBC runs twice a day:
  Batch 1 (2:30pm on T)
  Portfolios in Port Group TWFACAP1, and Portfolio Master -> Fund Admin as HSBC TW
  Batch 2 (10am on T+1)
  Portfolios in Port Group TWFACAP2 and TWFACAP3, and Portfolio Master -> Fund Admin as HSBC TW

  This feature file is to test below 2 scenarios -
  1. Loading 9 trade records, Out of which 2 trades which satisfies all filter condition should gets publish to HSBC.
  2. Loading 9 trade records, in which, 2 are existing one which got published in scenario 1; these 2 records should not get publish again in next publishing file.

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_TOM_4468.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_hsbc_FX_FWD_B1" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_FX_FWD_B1_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  #waiting intentionally
    And I pause for 20 seconds

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_4468.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_FRAP_HSBC_FX_FWD_B1_TOM_4468.sql
    """

  Scenario: Load Fresh data for Trades (6 Trade records)

    Given I assign "sm_TOM_4468.xml" to variable "INPUT_FILENAME1"
    And I assign "CounterParty_TOM_4468.xml" to variable "INPUT_FILENAME2"
    And I assign "tradefile_hsbc_FX_FWD_TOM_4468.xml" to variable "INPUT_FILENAME3"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID1}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

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

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME3}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect workflow is processed in DMP with total record count as "9"

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_FX_FWD_B1_01" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_FX_FWD_B1_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4468-302','4468-2776_valid_trade_parent','4468-4716_Index','4468-4716_Cust','4468-4722','4468-01','4468-02','4468-03') AND  END_TMS IS NULL
      )
     """

  Scenario: Verify trade recap HSBC file

    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "YYYYMMdd" and assign to "CURR_DATE"
    And I create input file "TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_01.csv" using template "TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_01_template.csv" with below codes from location "${testdata.path}/outfiles"
      |  |  |

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/testdata/TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_01.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_01.csv" file

  Scenario: Load confirmed trade to verify if it is getting published after Executed trade

    Given I assign "tradefile_hsbc_FX_FWD_update_TOM_4468.xml" to variable "INPUT_FILENAME4"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME4} |


    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME4}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID4"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID4}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 9
      AND TASK_CMPLTD_CNT = 9
      """

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_FX_FWD_B1_02" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_FX_FWD_B1_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4468-4468') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "YYYYMMdd" and assign to "CURR_DATE"
    And I create input file "TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_02.csv" using template "TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_02_template.csv" with below codes from location "${testdata.path}/outfiles"
      |  |  |

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/testdata/TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_02.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}TradeRecapExpected_hsbc_tom_4468_FX_FWD_B1_02.csv" file
