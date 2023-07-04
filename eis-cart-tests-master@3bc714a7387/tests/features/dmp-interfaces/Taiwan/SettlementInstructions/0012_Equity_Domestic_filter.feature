#https://jira.intranet.asia/browse/TOM-4610
#https://jira.intranet.asia/browse/TOM-4676
# EISDEV-7483 - Revert the FINS data update to avoid impacting other features

@dmp_regression_integrationtest
@tom_4610 @tw_settlement_instruction_format @tw_settlement_instruction_format_EQUITY_4610
@dmp_taiwan @tom_4676 @eisdev_7439 @eisdev_7483

Feature: Feature file for SI Equity PDF verification
  Load new portfolio, security, counterparty and trade file
  Perform verification of data inserted
  Publish PDF document by calling AOI workflow
  Verify whether PDF got published or not
  Fetch latest PDF file generated
  Compare the PDF file with expected PDF file
  Verify values in the PDF
  Verify occurrence of values in the PDF

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('4610-301') AND END_TMS IS NULL;
	 UPDATE FT_T_ETID SET END_TMS = SYSDATE
     WHERE EXEC_TRN_ID IN ('4610-301') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     UPDATE FT_T_ACID SET END_TMS = SYSDATE
     WHERE ACCT_ALT_ID = 'U_TT4464';
     COMMIT
    """

  Scenario: Assigning variables and executing clean up

    Given I assign "4610_PortfolioTemplate.xlsx" to variable "INPUT_FILENAME1"
    And I assign "4610_sm.xml" to variable "INPUT_FILENAME2"
    And I assign "4610_broker.xml" to variable "INPUT_FILENAME3"
    And I assign "4610_transaction.xml" to variable "INPUT_FILENAME4"

    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIR"

    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "ISIN" to variable "ISIN"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME4}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN}'"

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
    ${testdata.path}/sql/4610_InsertAccount.sql
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
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4610' and end_tms is null
    """

  Scenario: Performing transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4610-301' and end_tms is null
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

    And I execute below query to "Revert the Data Changes"
    """
    update ft_T_fins  set inst_nme='EASTSPRING INVESTMENTS LIMITED' where PREF_FINS_ID_CTXT_TYP ='INHOUSE' and  PREF_FINS_ID='ES-JP' and end_tms is null;
    """