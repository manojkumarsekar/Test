#https://jira.intranet.asia/browse/TOM-4192

@dmp_regression_unittest
@tom_4095 @tom_4192 @tw_settlement_instruction_format
@eisdev_7439

Feature:  Feature file for SI to check FAX and generate report
  Load new portfolio, security, counterparty and trade file
  Perform verification of data inserted
  Publish PDF document by calling AOI workflow if TRD_SETTLE_TEMPLATE_NAME contains FAX

  # TC 1 - To check generation of Report if FAX is not present in TRD_SETTLE_TEMPLATE_NAME
  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('4192-4192') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE
     WHERE EXEC_TRN_ID IN ('4192-4192') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     UPDATE FT_T_ACID SET END_TMS = SYSDATE
     WHERE ACCT_ALT_ID = 'TEST_4192';
     COMMIT
    """

  Scenario: Assigning variables and executing clean up

    Given I assign "008_4192_PortfolioTemplate.xlsx" to variable "INPUT_FILENAME1"
    And I assign "008_4192_broker.xml" to variable "INPUT_FILENAME2"
    And I assign "008_4192_sm.xml" to variable "INPUT_FILENAME3"
    And I assign "008_4192_transaction.xml" to variable "INPUT_FILENAME4"
    And I assign "008_4192_transaction_non_fax.xml" to variable "INPUT_FILENAME5"

    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIR"

    Then I extract value from the xml file "${testdata.path}/infiles/${INPUT_FILENAME4}" with tagName "CUSIP" to variable "CUSIP"
    Then I extract value from the xml file "${testdata.path}/infiles/${INPUT_FILENAME4}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf.error |

  Scenario: Load Portfolio, Security, Counterparty,trade file

    Given I process "${testdata.path}/infiles/${INPUT_FILENAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "3"

    And I execute below query
    """
     ${testdata.path}/sql/ACGP_4192.sql
    """

    And I process "${testdata.path}/infiles/${INPUT_FILENAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME3}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME3}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME4}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME4}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Performing verifications

    # Verfication
    And I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "3":
    """
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='TEST_4192' and end_tms is null
    """

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) SEC_ROW_COUNT from ft_t_isid where id_ctxt_typ = 'BCUSIP' and iss_id ='Y1434TCB7' and end_tms is null
    """

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4192' and end_tms is null
    """

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4192-4192' and end_tms is null
    """
    #waiting intentionally
    And I pause for 30 seconds

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
      WHERE TRD_ID = '4192-4192' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf.error |

  #TC 2- To check generation of Report if FAX is not present in TRD_SETTLE_TEMPLATE_NAME
  Scenario: Clear table data and setup variables

    Then I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('4192-4192') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE
     WHERE EXEC_TRN_ID IN ('4192-4192') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

  Scenario: Assigning variables and executing clean up

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf.error |

  Scenario: Load Transaction file

    And I process "${testdata.path}/infiles/${INPUT_FILENAME5}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME5}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Performing verifications

    # Verfication
    And I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "3":
    """
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='TEST_4192' and end_tms is null
    """

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) SEC_ROW_COUNT from ft_t_isid where id_ctxt_typ = 'BCUSIP' and iss_id ='Y1434TCB7' and end_tms is null
    """

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4192' and end_tms is null
    """

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4192-4192' and end_tms is null
    """
    #waiting intentionally
    And I pause for 30 seconds

  Scenario: Run publish document workflow for trade

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |

    #Verify Data
    Then I expect value of column "EXST_EIS_PROCESSED_ROW_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS EXST_EIS_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWSENT'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'EIS')
      AND EXST.DATA_SRC_ID = 'EIS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4192-4192' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf       |
      | 14022019_${PORTFOLIOCRTSID}_CASH_TD_*_NEWM_*.pdf.error |
