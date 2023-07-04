#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--1787168545
#https://jira.intranet.asia/browse/TOM-4744
#eisdev-6321: filter trader = itap records

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_securities @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan @tom_4744 @tom_4866 @tom_4882 @trade_recap @tom_4946 @tom_4979 @eisdev_6321
Feature: This feature file is to test Trade Recap CP/REP (money market) data published with Batch 2.

  Trade Recap to HSBC runs twice a day:
  Batch 1 (2:30pm on T)
  Portfolios in Port Group TWFACAP1, and Portfolio Master -> Fund Admin as HSBC TW
  Batch 2 (10am on T+1)
  Portfolios in Port Group TWFACAP2 and TWFACAP3, and Portfolio Master -> Fund Admin as HSBC TW

  This feature file is to test below 2 scenarios -
  1. Loading 9 trade records, Out of which 2 trades which satisfies all filter condition should gets publish to HSBC.
  2. Loading 12 trade records, in which, 2 are existing one which got published in scenario 1; these 2 records should not get publish again in next publishing file.

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_TOM_4744.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_hsbc_CP_REPO" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_CP_REP_B2_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  #waiting intentionally
    And I pause for 20 seconds

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_4744.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_FRAP_HSBC_CP_REP_B2_TOM_4744.sql
    """

  Scenario: Load Fresh data for Trades (6 Trade records)

    Given I assign "sm_TOM_4744.xml" to variable "INPUT_FILENAME1"
    And I assign "CounterParty_TOM_4744.xml" to variable "INPUT_FILENAME2"
    And I assign "tradefile_hsbc_CP_REPO_TOM_4744.xml" to variable "INPUT_FILENAME3"

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
      AND TASK_TOT_CNT = 4
      AND TASK_CMPLTD_CNT = 4
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

    And I expect workflow is processed in DMP with total record count as "10"

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_CP_REPO_B2_01" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_CP_REP_B2_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4744-302','4744-2776_valid_trade_parent','4744-4716_Index','4744-4716_Cust','4744-4722','4744-01','4744-02','4744-03') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/testdata/TradeRecapExpected_hsbc_tom_4744_CP_REPO_01.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}TradeRecapExpected_hsbc_tom_4744_CP_REPO_01.csv" file

  Scenario: Load confirmed trade to verify if it is getting published after Executed trade

    Given I assign "tradefile_hsbc_CP_REPO_update_TOM_4744.xml" to variable "INPUT_FILENAME1"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME1}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID1}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 12
      AND TASK_CMPLTD_CNT = 12
      """

    #Updates of COUP_FREQ to check else condition of day_ and month_
    And I execute below query
    """
      UPDATE FT_T_IEDF SET PY_DTE_FQ_SP_TYP = 'A' WHERE INSTR_ID IN (SELECT INSTR_ID FROM
      FT_T_ISID WHERE ISS_ID = 'TEST04744' AND ID_CTXT_TYP = 'BCUSIP' AND END_TMS IS NULL)
      AND PY_DTE_FQ_SP_TYP = 'M' AND END_TMS IS NULL;
      COMMIT
    """

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_CP_REPO_B2_02" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_CP_REP_B2_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

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
      WHERE TRD_ID in ('4744-303','4744-304') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC file

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/testdata/TradeRecapExpected_hsbc_tom_4744_CP_REPO_02.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}TradeRecapExpected_hsbc_tom_4744_CP_REPO_02.csv" file
