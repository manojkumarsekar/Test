#https://jira.intranet.asia/browse/TOM-4298
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMTN&title=Taiwan+FX+-+Synthetic+Transfer+from+Main+to+Sub#businessRequirements-dataRequirement
#https://jira.pruconnect.net/browse/EISDEV-4964 - Update Portfolio Logic for Synthetic CFE from Main to Sub for TWD FX currency pair
#                                               - In this JIRA, NPP flag is checked for sub portfolio and it is included in publishing if it is 'N' otherwise not.
  
@tom_4298 @dmp_interfaces @dmp_taiwan @dmp_regression_integrationtest @tom_4915 @tom_4964

Feature: Feature file for cash transaction File 367 FX Synthetic transfer Main to Sub Outbound
  Load new portfolio, security, counterparty and trade file to set up required data
  Publish file for FX Synthetic transfer Main to Sub File 367.


  Scenario: TC_1: Clear dummy table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"

    And I execute below query
      """
     ${testdata.path}/sql/4298_Clear_script.sql
      """

  Scenario: TC_2: Assigning variables and executing clean up

    Given I assign "4298_PortfolioTemplate_Split1.xlsx" to variable "INPUT_FILENAME1"
    And I assign "4298_sm.xml" to variable "INPUT_FILENAME2"
    And I assign "4298_broker.xml" to variable "INPUT_FILENAME3"
    And I assign "4298_transaction.xml" to variable "INPUT_FILENAME4"
    And I assign "4298_transaction_canc.xml" to variable "INPUT_FILENAME5"

    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |
      | ${INPUT_FILENAME4} |
      | ${INPUT_FILENAME5} |

  Scenario: TC_3: Load Portfolio, Security, Counterparty and trade file

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='5'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='2'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME3}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID3}' and TASK_SUCCESS_CNT ='1'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME4}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID4"

    And I expect workflow is processed in DMP with success record count as "3"

  Scenario: TC_4: Performing portfolio verification

    # Verfication
    And I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "5":
      """
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='U_TT4298' and end_tms is null
      """

  Scenario: TC_5: Performing Security verification

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
      """
      select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='TEST42988' and end_tms is null
      """

  Scenario: TC_6: Performing trade verification for TT37- Trade_id 3503-125 for portfolio TT37 with child portfolio TT37_S having NPP flag as Y is loaded in DMP. This trade should not be published.

    And I expect value of column "TRD_ROW_COUNT" in the below SQL query equals to "1":
      """
      select count(*) TRD_ROW_COUNT from ft_t_extr where acct_id in (select acct_id from fT_t_acid where acct_alt_id ='TT37' and acct_id_ctxt_typ ='CRTSID' and end_tms is null) and trd_id ='3503-125' and end_Tms is null
      """

  Scenario: TC_7: Performing broker verification

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "4":
      """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4298' and end_tms is null
      """

  Scenario: TC_8: Performing transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "2":
      """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id in ('4298-4298','TEST4298-TEST4298') and end_tms is null
      """

  Scenario: TC_9: Set up required ACGP, ACCT, ACID and ACCR data linked to above transaction and portfolio

    And I execute below query
      """
     ${testdata.path}/sql/4298_DUMMY_ACGP_Insert.sql
      """

  Scenario: TC_10: Publish Cash Transaction File 367 - FX SYNTH for NEWM trades
  Transaction data present with NEWM status and SPLIT portfolios
  Newline#1 have TICKER != TWD
  Newline#2 have TRD_CURRENCY != TWD
  Expected : Trade_id 3503-125 should not be published

    Given I assign "esi_TW_newcash_4298_NEWM" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_11: Check if published file contains data for cash transaction data for NEWM with sub custodian value

    Given I assign "4298_NEWM_EXPECTED.csv" to variable "4298_NEWM_EXPECTED"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "4298_NEWM_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${4298_NEWM_EXPECTED}" should exist in file "${testdata.path}/outfiles/actual/${4298_NEWM_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_12: Load update of Transaction file for CANC status

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME5}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID5"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID5}' and TASK_SUCCESS_CNT ='2'
      """

  Scenario: TC_13: Publish Cash Transaction File 367 - FX SYNTH for CANC
  Transaction data present with NEWM status and SPLIT portfolios
  Newline#1 have TICKER != TWD
  Newline#2 have TRD_CURRENCY != TWD

    Given I assign "esi_TW_newcash_4298_CANC" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_CANC |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_14: Check if published file contains data for cash transaction data for CANC with main custodian value

    Given I assign "4298_CANC_EXPECTED.csv" to variable "4298_CANC_EXPECTED"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "4298_CANC_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${4298_CANC_EXPECTED}" should exist in file "${testdata.path}/outfiles/actual/${4298_CANC_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file

