#https://jira.intranet.asia/browse/TOM-4425

@tom_4425 @tom_4425_SI
Feature: Feature file for SI TimeDeposit PDF verification
Load new portfolio, security, counterparty and trade file
Perform verification of data inserted
Publish PDF document by calling AOI workflow
Verify whether PDF got published or not
Fetch latest PDF file generated
Compare the PDF file with expected PDF file
Verify values in the PDF
Verify occurrence of values in the PDF

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/Insight/TimeDeposit" to variable "testdata.path"

    And I execute below query
    """
   ${testdata.path}/sql/InsertAccount.sql
    """

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('4267-4267') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE
     WHERE EXEC_TRN_ID IN ('4267-4267') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     UPDATE FT_T_ACID SET END_TMS = SYSDATE
     WHERE ACCT_ALT_ID = 'U_TT12';
     COMMIT
    """

  Scenario: Assigning variables and executing clean up

    Given I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME1"
    And I assign "sm.xml" to variable "INPUT_FILENAME2"
    And I assign "broker.xml" to variable "INPUT_FILENAME3"
    And I assign "transaction.xml" to variable "INPUT_FILENAME4"

    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIR"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |
      | ${INPUT_FILENAME4} |


    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "CUSIP" to variable "CUSIP"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 4267-4267_${PORTFOLIOCRTSID}_${CUSIP}_*_NEWM_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 4267-4267_${PORTFOLIOCRTSID}_${CUSIP}_*_NEWM_*.pdf.error |

  Scenario: Load Portfolio, Security, Counterparty,trade file

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='3'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='1'
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

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID4}' and TASK_SUCCESS_CNT ='1'
      """

  Scenario: Performing portfolio verification

    # Verfication
    And I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "3":
    """
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='U_TT12' and end_tms is null
      """

  Scenario: Performing Security verification

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='BPM2EATZ0' and end_tms is null
      """

  Scenario: Performing broker verification

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4267' and end_tms is null
      """

  Scenario: Performing transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4267-4267' and end_tms is null
      """

  Scenario: Run publish document workflow for trade

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}             |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |


   #Verify Data
    Then I expect value of column "EXST_EIS_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_EIS_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWSENT'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'EIS')
      AND EXST.DATA_SRC_ID = 'EIS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4267-4267' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | 4267-4267_${PORTFOLIOCRTSID}_${CUSIP}_*_NEWM_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | 4267-4267_${PORTFOLIOCRTSID}_${CUSIP}_*_NEWM_*.pdf.error |

  Scenario: Loading PDF file in local and performing direct PDF comparison with expected PDF

    Given I assign "4267-4267_U_TT12_BPM2EATZ0_TIMEDEPOSIT_BASE.pdf" to variable "EXPECTED_FILE"

    When I read latest file with the pattern "4267-4267_${PORTFOLIOCRTSID}_${CUSIP}_*_NEWM_*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_FILE_NAME"

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | "${LATEST_FILE_NAME}" |

    Then I consider below content to be excluded in pdf comparison with TEXT mode
      | 2019/04/01 18:10:04.826000   |

    Then I expect below pdf files should be identical
      | ${testdata.path}/outfiles/expected/${EXPECTED_FILE} |
      | ${testdata.path}/outfiles/runtime/${LATEST_FILE_NAME} |

  Scenario: Loading PDF file for processing and checking expected values

    When I load pdf file "${testdata.path}/outfiles/runtime/${LATEST_FILE_NAME}" for processing

    Then I expect pdf file should contains below values
      | Eastspring Securities Investment Trust Company Limited |
      | UAT Eastspring Investments Well Pool Money Market Fund |
      | Time Deposit Settlement Instructions |
      | DBS Bank (Taiwan) Ltd. |
      | CITIBANK MALAYSIA |
      | 4267-4267 |
      | BUY |
      | 2019/02/14 |
      | 2020/02/14 |
      | FIXED |
      | 300,000,000.0000 |
      | 0.8000 |
      | 0.0000 |
      | Bank Name:DBS Bank (Taiwan) |
      | Bank Code:8100364 |
      | Branch Name:Nanjing Branch |

  Scenario: Checking occurrences of each values in PDF

    Then I expect pdf file should contains below values with given expected number of occurrences
      | Eastspring Securities Investment Trust Company Limited | 1 |
      | UAT Eastspring Investments Well Pool Money Market Fund | 1 |
      | Time Deposit Settlement Instructions | 1 |
      | DBS Bank (Taiwan) Ltd. | 1 |
      | CITIBANK MALAYSIA | 1 |
      | 4267-4267 | 1 |
      | BUY | 1 |
      | 2019/02/14 | 1 |
      | 2020/02/14 | 1 |
      | FIXED | 1 |
      | 300,000,000.0000 | 3 |
      | 0.8000 | 1 |
      | 0.0000 | 5 |
      | Bank Name:DBS Bank (Taiwan) | 1 |
      | Bank Code:8100364 | 1 |
      | Branch Name:Nanjing Branch | 1 |