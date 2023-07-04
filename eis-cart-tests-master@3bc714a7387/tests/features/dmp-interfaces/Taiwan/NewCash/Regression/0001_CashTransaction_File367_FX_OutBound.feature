#https://jira.intranet.asia/browse/TOM-4422
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887327#businessRequirements-dataRequirement
# https://jira.pruconnect.net/browse/EISDEV-6071 -- failed in regression finr script added

# ===================================================================================================================================================================================
# Date            JIRA         Comments
# ===================================================================================================================================================================================
# 19/02/2020      EISDEV-6071  Regression failure :Feature file
# ===================================================================================================================================================================================

@gc_interface_cash @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities @gc_interface_counterparty
@dmp_regression_integrationtest  @eisdev_7373
@dmp_taiwan
@tom_4422 @tw_fx_trade_file367 @eisdev_6071 @eisdev_7108
Feature: Feature file for cash transaction File 367 FX Outbound

  Load new portfolio, security, counterparty and trade file to set up required data
  Publish file for FX File 367

  Scenario: TC_1: Clear dummy table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/4422_Clear_script.sql
    """

    And I execute below query to "Insert FT_T_FINR entry"
    """
    ${testdata.path}/sql/6071_FinrInsert.sql
    """

  Scenario: TC_2: Assigning variables and executing clean up

    Given I assign "4422_PortfolioTemplate_ShareClass1.xlsx" to variable "INPUT_FILENAME1"
    And I assign "4422_PortfolioTemplate_Main.xlsx" to variable "INPUT_FILENAME2"
    And I assign "4422_PortfolioTemplate_Split1.xlsx" to variable "INPUT_FILENAME3"
    And I assign "4422_sm.xml" to variable "INPUT_FILENAME4"
    And I assign "4422_broker.xml" to variable "INPUT_FILENAME5"
    And I assign "4422_transaction.xml" to variable "INPUT_FILENAME6"
    And I assign "4422_transaction_canc.xml" to variable "INPUT_FILENAME7"

    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |
      | ${INPUT_FILENAME4} |
      | ${INPUT_FILENAME5} |
      | ${INPUT_FILENAME6} |
      | ${INPUT_FILENAME7} |

  Scenario: TC_3: Load Portfolio, Security, Counterparty,trade file

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='6'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME2}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='3'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME3}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID3}' and TASK_SUCCESS_CNT ='5'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME4}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID4"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID4}' and TASK_SUCCESS_CNT ='1'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME5}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |

    Then I extract new job id from jblg table into a variable "JOB_ID5"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID5}' and TASK_SUCCESS_CNT ='1'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME6}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID6"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID6}' and TASK_SUCCESS_CNT ='1'
      """

  Scenario: TC_4: Performing portfolio verification

    # Verfication
    And I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "5":
      """
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='U_TT4422' and end_tms is null
      """

  Scenario: TC_5: Performing Security verification

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
      """
      select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='TEST44228' and end_tms is null
      """

  Scenario: TC_6: Performing broker verification

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
      """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4422' and end_tms is null
      """

  Scenario: TC_7: Performing transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
      """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4422-4422' and end_tms is null
      """

  Scenario: TC_8: Set up required ACGP, ACCT, ACID and ACCR data linked to above transaction and portfolio

    And I execute below query
      """
     ${testdata.path}/sql/4422_DUMMY_ACGP_Insert.sql
      """

  Scenario: TC_9: Publish Cash Transaction File 367 - FX for NEWM
  Transaction data present with NEWM status and SPLIT portfolios
  Newline#1 have currency USD i.e not equal to TWD hence sub-custodian portfolio should get published
  Newline#2 have currency TWD hence Main portfolio should get published

    Given I assign "esi_TW_newcash_4422_NEWM" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_10: Check if published file contains data for cash transaction data for NEWM with sub custodian value

    Given I assign "4422_NEWM_EXPECTED.csv" to variable "4422_NEWM_EXPECTED"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "4422_NEWM_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${4422_NEWM_EXPECTED}" should exist in file "${testdata.path}/outfiles/actual/${4422_NEWM_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_11: DELETE SPLIT ACCR data to test Portfolio logic

    And I execute below query
    """
   ${testdata.path}/sql/4422_Delete_Split_ACCR.sql
    """

  Scenario: TC_12: Publish Cash Transaction File 367 - FX for NEWM
  Transaction data present with NEWM status and with No SPLIT portfolios
  Newline#1 and Newline#2 should get published with Main portfolio as no split portfolio present

    Given I assign "esi_TW_newcash_4422_NEWM_WITHOUT_SPLIT" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_13: Check if published file contains data for cash transaction data for NEWM with main custodian value

    Given I assign "4422_NEWM_WITHOUT_SPLIT_EXPECTED.csv" to variable "4422_NEWM_WITHOUT_SPLIT_EXPECTED"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "4422_NEWM_WITHOUT_SPLIT_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${4422_NEWM_WITHOUT_SPLIT_EXPECTED}" should exist in file "${testdata.path}/outfiles/actual/${4422_NEWM_WITHOUT_SPLIT_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_14: Load update of Transaction file for CANC status

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME7}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID7"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID7}' and TASK_SUCCESS_CNT ='1'
      """

  Scenario: TC_15: Publish Cash Transaction File 367 - FX for CANC
  Transaction data present with CANC status and with No SPLIT portfolios
  Newline#1 and Newline#2 should get published with Main portfolio as no split portfolio present

    Given I assign "esi_TW_newcash_4422_CANC" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_CANC |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_16: Check if published file contains data for cash transaction data for CANC with main custodian value

    Given I assign "4422_CANC_EXPECTED.csv" to variable "4422_CANC_EXPECTED"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "4422_CANC_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${4422_CANC_EXPECTED}" should exist in file "${testdata.path}/outfiles/actual/${4422_CANC_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file

