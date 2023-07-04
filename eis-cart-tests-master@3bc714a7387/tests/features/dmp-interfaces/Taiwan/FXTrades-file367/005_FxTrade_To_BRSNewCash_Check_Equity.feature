#https://jira.intranet.asia/browse/TOM-4422
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887327#businessRequirements-dataRequirement


@gc_interface_cash @gc_interface_securities @gc_interface_portfolios @gc_interface_transactions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4422 @tw_equity_file367_filtercriteria @tw_fx_trade_file367
Feature: Load BRS Equity transaction for filter criteria and check file 367 is not generated

  The purpose of this feature file is to check when trade do not satisfy the filter criteria then file 367 is not getting generated

  Scenario: TC1: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/FXTrades-file367" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "001_NewCash_BRSFile" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "etf_sm_file.xml" to variable "INPUT_FILENAME_EQUITY"
    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME_PORTFOLIO"
    And I assign "S66834052" to variable "CUSIP1"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${CUSIP1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP1}'"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EQUITY}    |
      | ${INPUT_FILENAME_PORTFOLIO} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME_EQUITY} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW  |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='2'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_PORTFOLIO}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='8'
    """

  Scenario: validate SSI report for ETF trade
    Given I assign "Equity_transaction.xml" to variable "INPUT_FILENAME"

    #End TMS existing trades to avoid load error
    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3497-TEST_ETF') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3497-TEST_ETF') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

    And I copy files below from local folder "${testdata.path}/infiles/template" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

