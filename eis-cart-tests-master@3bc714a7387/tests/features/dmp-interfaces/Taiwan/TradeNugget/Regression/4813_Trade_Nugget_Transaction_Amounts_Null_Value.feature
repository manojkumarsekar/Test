#https://jira.intranet.asia/browse/TOM-4813
#https://jira.intranet.asia/browse/TOM-4861
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 19/02/2020      EISDEV-6071  Regression failure :Feature file
# ===================================================================================================================================================================================

@gc_interface_portfolios @gc_interface_securities @gc_interface_transactions @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan @eisdev_7373
@tom_4813 @tom_4861 @eisdev_6071 @eisdev_7108
Feature: Feature file for verification whether amount fields are setting up as null

  1. Load new portfolio, security, counterparty and trade file
  2. Check whether data inserted in columns FX_PAY_AMT, FX_RCV_AMT, TRD_COMMISSION, TRDCHARGE, TRD_COUPON, TRD_INTEREST, TRD_OTHER_FEE, TRD_YIELD, UDF (TW CP_Intr_Tax) is not zero
  3. Load revised trade file
  4. Check whether data inserted in columns FX_PAY_AMT, FX_RCV_AMT, TRD_COMMISSION, TRDCHARGE, TRD_COUPON, TRD_INTEREST, TRD_OTHER_FEE, TRD_YIELD, UDF (TW CP_Intr_Tax) is zero

  Scenario: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget/TOM-4813" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('4813-4813') AND END_TMS IS NULL;
    UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('4813-4813') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND END_TMS IS NULL;
    UPDATE FT_T_ACID SET END_TMS = SYSDATE WHERE ACCT_ALT_ID = 'U_TT4813';
    COMMIT
    """

    And I execute below query to "Insert FT_T_FINR entry"
    """
    ${testdata.path}/sql/4813_InsertAccount.sql;
    ${testdata.path}/sql/6071_FinrInsert.sql
    """

  Scenario: Assigning variables and executing clean up

    Given I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME1"
    And I assign "sm.xml" to variable "INPUT_FILENAME2"
    And I assign "broker.xml" to variable "INPUT_FILENAME3"
    And I assign "transaction.xml" to variable "INPUT_FILENAME4"
    And I assign "transaction_revised.xml" to variable "INPUT_FILENAME5"

    And I copy files below from local folder "${testdata.path}/infiles/" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |
      | ${INPUT_FILENAME4} |
      | ${INPUT_FILENAME5} |

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
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='U_TT4813' and end_tms is null
    """

  Scenario: Performing Security verification

    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='BPM00H0T9' and end_tms is null
    """

  Scenario: Performing broker verification

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_4813' and end_tms is null
    """

  Scenario: Performing transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4813-4813' and end_tms is null
    """

  Scenario Outline: Verify the data uploaded in column <Column> is not zero via intial version of trade file

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

    Examples: Data Verifications having value not zero
      | Column         | Query                                                                                                                                                                                                                                                                     |
      | FX_PAY_AMT     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FX_PAY_AMT FROM FT_T_EXTR EXTR, FT_T_EXFX EXFX WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFX.EXEC_TRD_ID AND EXFX.TO_CURR_CAMT <>0                                     |
      | FX_RCV_AMT     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FX_RCV_AMT FROM FT_T_EXTR EXTR, FT_T_EXFX EXFX WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFX.EXEC_TRD_ID AND EXFX.FROM_CURR_CAMT <>0                                   |
      | TRD_COMMISSION | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_COMMISSION FROM FT_T_EXTR EXTR, FT_T_ETPY ETPY WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETPY.EXEC_TRD_ID  AND EXEC_TRD_PAY_TYP = 'TRDCOMM' AND ETPY.PAY_CAMT <>0   |
      | TRDCHARGE      | SELECT CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS TRDCHARGE FROM FT_T_EXTR EXTR, FT_T_ETPY ETPY WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETPY.EXEC_TRD_ID  AND EXEC_TRD_PAY_TYP IN ('LOCO','TRAN') AND ETPY.PAY_CAMT <>0 |
      | TRD_COUPON     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_COUPON FROM FT_T_EXTR EXTR, FT_T_EXFI EXFI WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFI.EXEC_TRD_ID AND EXFI.CRRNT_YLD_CPCT <>0                                   |
      | TRD_YIELD      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_YIELD FROM FT_T_EXTR EXTR, FT_T_EXFI EXFI WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFI.EXEC_TRD_ID AND EXFI.WORST_YIELD_CPCT <>0                                  |
      | TW_CP_INTR_TAX | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TW_CP_INTR_TAX FROM FT_T_EXTR EXTR, FT_T_ETPY ETPY WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETPY.EXEC_TRD_ID  AND EXEC_TRD_PAY_TYP = 'TWCPINTTX' AND ETPY.PAY_CAMT <>0 |
      | TRD_INTEREST   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_INTEREST FROM FT_T_EXTR EXTR, FT_T_ETAM ETAM WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETAM.EXEC_TRD_ID AND ETAM.TRADED_IN_CAMT <> 0                                |
      | TRD_OTHER_FEE  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_OTHER_FEE FROM FT_T_EXTR EXTR, FT_T_ETAM ETAM WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETAM.EXEC_TRD_ID AND ETAM.MISC_FEE_CAMT <> 0                                |

  Scenario: Load revised trade file with columns FX_PAY_AMT, FX_RCV_AMT, TRD_COMMISSION, TRDCHARGE, TRD_COUPON, TRD_INTEREST, TRD_OTHER_FEE, TRD_YIELD, UDF (TW CP_Intr_Tax) having value as zero.

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME5}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID5"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID5}' and TASK_SUCCESS_CNT ='1'
    """

  Scenario: Performing revised transaction verification

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4813-4813' and end_tms is null
    """

  Scenario Outline: Verify the data uploaded in column <Column> is zero via revised version of trade file

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

    Examples: Data Verifications having value zero
      | Column         | Query                                                                                                                                                                                                                                                                         |
      | FX_PAY_AMT     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FX_PAY_AMT FROM FT_T_EXTR EXTR, FT_T_EXFX EXFX WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFX.EXEC_TRD_ID AND EXFX.TO_CURR_CAMT IS NULL                                     |
      | FX_RCV_AMT     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FX_RCV_AMT FROM FT_T_EXTR EXTR, FT_T_EXFX EXFX WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFX.EXEC_TRD_ID AND EXFX.FROM_CURR_CAMT IS NULL                                   |
      | TRD_COMMISSION | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_COMMISSION FROM FT_T_EXTR EXTR, FT_T_ETPY ETPY WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETPY.EXEC_TRD_ID  AND EXEC_TRD_PAY_TYP = 'TRDCOMM' AND ETPY.PAY_CAMT IS NULL   |
      | TRDCHARGE      | SELECT CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS TRDCHARGE FROM FT_T_EXTR EXTR, FT_T_ETPY ETPY WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETPY.EXEC_TRD_ID  AND EXEC_TRD_PAY_TYP IN ('LOCO','TRAN') AND ETPY.PAY_CAMT IS NULL |
      | TRD_COUPON     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_COUPON FROM FT_T_EXTR EXTR, FT_T_EXFI EXFI WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFI.EXEC_TRD_ID AND EXFI.CRRNT_YLD_CPCT IS NULL                                   |
      | TRD_YIELD      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_YIELD FROM FT_T_EXTR EXTR, FT_T_EXFI EXFI WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = EXFI.EXEC_TRD_ID AND EXFI.WORST_YIELD_CPCT IS NULL                                  |
      | TW_CP_INTR_TAX | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TW_CP_INTR_TAX FROM FT_T_EXTR EXTR, FT_T_ETPY ETPY WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETPY.EXEC_TRD_ID  AND EXEC_TRD_PAY_TYP = 'TWCPINTTX' AND ETPY.PAY_CAMT IS NULL |
      | TRD_INTEREST   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_INTEREST FROM FT_T_EXTR EXTR, FT_T_ETAM ETAM WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETAM.EXEC_TRD_ID AND ETAM.TRADED_IN_CAMT IS NULL                                 |
      | TRD_OTHER_FEE  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_OTHER_FEE FROM FT_T_EXTR EXTR, FT_T_ETAM ETAM WHERE EXTR.TRD_ID ='4813-4813' AND EXTR.END_TMS IS NULL AND EXTR.EXEC_TRD_ID = ETAM.EXEC_TRD_ID AND ETAM.MISC_FEE_CAMT IS NULL                                 |