#https://jira.intranet.asia/browse/TOM-4720

@dmp_regression_integrationtest
@tw_settlement_instruction_format @tw_settlement_instruction_format_EQUITY
@tom_4720 @eisdev_7439

Feature: Feature file for SI Equity PDF verification with and without ETF tag

  1. Load new portfolio, security, counterparty and trade file
  2. Perform verification of data inserted
  3. Publish PDF document by calling AOI workflow
  4. Verify whether PDF got published or not
  5. Fetch latest PDF file generated
  6. Compare the PDF file with expected PDF file
  7. Verify values in the PDF
  8. Verify occurrence of values in the PDF
  9. Load modified security file with ETF tag
  10. Perform verification of data modified
  11. Publish PDF document by calling AOI workflow
  12. Verify that PDF is not published

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/Insight/Equity" to variable "testdata.path"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('14876-301') AND END_TMS IS NULL;
	 UPDATE FT_T_ETID SET END_TMS = SYSDATE
     WHERE EXEC_TRN_ID IN ('14876-301') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     UPDATE FT_T_ACID SET END_TMS = SYSDATE
     WHERE ACCT_ALT_ID = 'U_TT4464';
     COMMIT
    """

  Scenario: Assigning variables and executing clean up

    Given I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME1"
    And I assign "sm.xml" to variable "INPUT_FILENAME2"
    And I assign "broker.xml" to variable "INPUT_FILENAME3"
    And I assign "transaction.xml" to variable "INPUT_FILENAME4"
    And I assign "sm_etf_filter_check.xml" to variable "INPUT_FILENAME5"

    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIR"

    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "ISIN" to variable "ISIN"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "CUSIP" to variable "CUSIP"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP}'"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf.error |

  Scenario: Load Portfolio, Security, Counterparty,trade file

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "3"

    And I execute below query
    """
      ${testdata.path}/sql/InsertAccount.sql
    """

    And I process "${testdata.path}/testdata/${INPUT_FILENAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I process "${testdata.path}/testdata/${INPUT_FILENAME3}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME3}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I process "${testdata.path}/testdata/${INPUT_FILENAME4}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME4}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Performing portfolio verification

    # Verfication
    And I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "3":
    """
    select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='U_TT4464' and end_tms is null
    """

  Scenario: Performing Security verification

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
    select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='0044644' and end_tms is null
    """

  Scenario: Performing broker verification

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
    """
    select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4464' and end_tms is null
    """

  Scenario: Performing transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
    select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='14876-301' and end_tms is null
    """

  Scenario: Run publish document workflow for trade

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
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
      WHERE TRD_ID = '14876-301' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf.error |

  Scenario: Loading PDF file in local and performing direct PDF comparison with expected PDF

    Given I assign "14876-301_EQUITY_BASE.pdf" to variable "EXPECTED_FILE"

    When I read latest file with the pattern "20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_FILE_NAME"

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | "${LATEST_FILE_NAME}" |

    Then I consider below content to be excluded in pdf comparison with TEXT mode
      | 2019/06/12 18:06:50 |

    Then I expect below pdf files should be identical
      | ${testdata.path}/outfiles/expected/${EXPECTED_FILE}   |
      | ${testdata.path}/outfiles/runtime/${LATEST_FILE_NAME} |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf.error |

  Scenario: Load Security file with ETF filter

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME5}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME5}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Performing Security verification

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
    select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='0044644' and end_tms is null
    """

  Scenario: Run publish document workflow for trade

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |


    #Verify if PUB1 entry is updated succesfully
    Then I expect value of column "NOROWPUB1COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS NOROWPUB1COUNT FROM FT_CFG_PUB1
    WHERE  PUB_STATUS = 'CLOSED'
    AND PUB_DESCRIPTION='No rows found by the publishing query'
    AND  PUB_CNT =0
    AND START_TMS > (SELECT START_TMS
    FROM (SELECT pub1.START_TMS, row_number() OVER (ORDER BY START_tMS DESC) rnum
          FROM FT_CFG_PUB1 pub1)
          WHERE rnum = 2)
    """

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | 20022019_${PORTFOLIOCRTSID}_EQUITY_EQUITY_*_NEWM*.pdf |