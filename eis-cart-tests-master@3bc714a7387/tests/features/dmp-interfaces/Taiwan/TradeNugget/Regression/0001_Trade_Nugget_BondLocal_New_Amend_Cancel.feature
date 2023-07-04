#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades

@gc_interface_transactions
@dmp_regression_unittest
@dmp_taiwan
@tom_3844 @tom_3385 @tw_bondlocal_trades
Feature: TW Intraday Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Verify Bond local loaded in DMP

  Scenario: TC1: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET END_TMS = SYSDATE
    WHERE TRD_ID IN ('12627-39') AND END_TMS IS NULL;
    UPDATE FT_T_ETID SET END_TMS = SYSDATE
    WHERE EXEC_TRN_ID IN ('12627-39') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """

    And I execute below query and extract values of "PORTFOLIO_NAME" into same variables
    """
    SELECT ACCT_ALT_ID AS PORTFOLIO_NAME FROM ft_t_acid where acct_id_ctxt_typ = 'CRTSID' AND ACCT_ALT_ID like 'TT%'  AND end_tms IS NULL  ORDER  BY 1 DESC
    """

  Scenario: TC2: Load Trades file for new Bond Local security transaction in portfolio TT56 (INVNUM=-39)
  Expected Result: 1) File should load and make entry in jblg
  2) Verify a new record created for this transaction and all the required fields are mapped properly in DMP

    Given I assign "BondLocal_transaction_New_Tem.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "BondLocal_transaction_New.xml" to variable "INPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" from location "${testdata.path}/infiles"

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
    """

    # Check if EXTR is created with check TRD_ID, Tran_Type1, TradeDate, Settledate, Trd_CCy, Trd_Price, Trd_Org_Face from test data
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
    FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND   EXEC_TRN_CAT_TYP = 'TRD' AND TO_CHAR (TRD_DTE, 'MM/DD/YYYY') = '11/27/2018'
    AND TO_CHAR (SETTLE_DTE, 'MM/DD/YYYY') = '11/30/2018'
    AND TRD_CURR_CDE = 'TWD' AND TRD_CPRC = '54.0000' AND  TRN_CDE = 'BRSEOD' AND TRD_CQTY = '100.1430000000' AND END_TMS IS NULL
    """

    # Check if ETAM is created with data present in the test file (TRD_CURRENCY, TRD_INTEREST,TRD_OTHER_FEE,TRD_PRINCIPAL,INT_AT_MATURITY)
    And I expect value of column "ETAM_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ETAM_PROCESSED_ROW_COUNT FROM FT_T_ETAM
    WHERE EXTN_CURR_CDE = 'TWD' AND NET_SETTLE_CAMT = '54.0000000000'
    AND TRADED_IN_CAMT = '1.0000000000' AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

    # Check if ETID is created with data present in the test file (Fund+ Inv Num)
    And I expect value of column "ETID_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ETID_PROCESSED_ROW_COUNT
    FROM FT_T_ETID WHERE EXEC_TRN_ID_CTXT_TYP IN( 'BRSTRNID')
    AND EXEC_TRN_ID ='12627-39'
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

    # Check if EXST is created with data present in the test file (TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST
    WHERE EXEC_TRD_STAT_TYP = 'NEWM' AND   GEN_CNT = 1
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND  END_TMS IS NULL
    )
    """

    # Check if TRCP is created with data present in the test file (TRD_COUNTERPARTY)
    And I expect value of column "TRCP_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS TRCP_PROCESSED_ROW_COUNT FROM FT_T_TRCP
    WHERE CNTPRTY_ID_CTXT_TYP = 'COUNTERPARTY' AND CNTPRTY_ID ='CITI-TW'
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

    # Check if ETCM is created with data present in the test file(TRD_REVIEW_TIME, TRD_REVIEWED_BY, TRDCOMM_COMMENTS, FX_PAY_SI, FX_RCV_SI, TRD_Trader, SI, TRD_MODIFIED_BY )
    And I expect value of column "ETCM_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS ETCM_PROCESSED_ROW_COUNT FROM FT_T_ETCM
    WHERE CMNT_REAS_TYP IN ('TRADER', 'TRDMODBY', 'TRDREVIEW', 'TRDCOMMENTS', 'SETTINST', 'FXPAYSI', 'FXRCVSI')
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

    # Check if ETCL is created with data present in the test file(TRAN_TYPE_DERIV,TRD_FLAGS,TRAN_TYPE)
    And I expect value of column "ETCL_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ETCL_PROCESSED_ROW_COUNT FROM FT_T_ETCL
    WHERE INDUS_CL_SET_ID IN ('BRSTRNDERI', 'BRSTRTYP', 'BRSTRDFLAG')
    AND CL_VALUE IN ('','BUY','')
    AND  EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

     # Check if EXMB is created with data present in the test file(TRD_TD_PAR,TRD_FACTOR,TRD_ORIG_FACE)
    And I expect value of column "EXMB_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXMB_PROCESSED_ROW_COUNT FROM FT_T_EXMB
    WHERE MBS_TRD_TYP = 'ALLOC'
    AND CRRNT_FACE_CAMT = '100.1430000000'
    AND POOL_FACTOR_CRTE = '1.0000000000'
    AND ORIG_FACE_CAMT = '100.1430000000'
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND  END_TMS IS NULL
    )
    """

    # Check if EXFI is created with data present in the test file(TRD_YIELD,TRD_YIELD_TO_CALL,TRD_DIRTY_PRICE)
    And I expect value of column "EXFI_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXFI_PROCESSED_ROW_COUNT FROM FT_T_EXFI
    WHERE WORST_YIELD_CPCT = '80.2567103500' AND   EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

  Scenario: TC3: Load Trades file for amended Bond Local security transaction in portfolio TT56 (INVNUM=-39)
  Expected Result: 1) File should load and make entry in jblg
  2) Verify old record updated for this transaction instead of creating the new record in DMP

    Given I assign "BondLocal_transaction_Amend_Tem.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "BondLocal_transaction_Amend.xml" to variable "INPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" from location "${testdata.path}/infiles"

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
    """

    # Check if EXTR is created with check TRD_ID, Tran_Type1, TradeDate, Settledate, Trd_CCy, Trd_Price, Trd_Org_Face from test data
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
    FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND   EXEC_TRN_CAT_TYP = 'TRD' AND TO_CHAR (TRD_DTE, 'MM/DD/YYYY') = '11/27/2018'
    AND TO_CHAR (SETTLE_DTE, 'MM/DD/YYYY') = '11/30/2018'
    AND TRD_CURR_CDE = 'TWD' AND TRD_CPRC = '55.0000000000' AND  TRN_CDE = 'BRSEOD' AND TRD_CQTY = '300.1430000000' AND END_TMS IS NULL
    """

    # Check if EXST is created with data present in the test file
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST
    WHERE EXEC_TRD_STAT_TYP = 'NEWM' AND   GEN_CNT = 2
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

     # Check if EXMB is created with data present in the test file
    And I expect value of column "EXMB_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXMB_PROCESSED_ROW_COUNT FROM FT_T_EXMB
    WHERE MBS_TRD_TYP = 'ALLOC'
    AND CRRNT_FACE_CAMT = '100.1430000000'
    AND POOL_FACTOR_CRTE = '1.0000000000'
    AND ORIG_FACE_CAMT = '300.1430000000'
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """

  Scenario: TC4: Load cancelled Trades file for Bond Local security transaction in portfolio TT56 (INVNUM=-39)
  Expected Result: 1) File should load and make entry in jblg
  2) Verify old record cancelled for this transaction instead of creating the new record in DMP

    Given I assign "BondLocal_transaction_Cancel_Tem.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "BondLocal_transaction_Cancel.xml" to variable "INPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" from location "${testdata.path}/infiles"

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
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

    # Check if EXTR is created with check TRD_ID, Tran_Type1, TradeDate, Settledate, Trd_CCy, Trd_Price, Trd_Org_Face from test data
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
    FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    """

    # Check if EXST is created with data present in the test file
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST
    WHERE EXEC_TRD_STAT_TYP = 'CANC' AND   GEN_CNT = 3
    AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '12627-39' AND END_TMS IS NULL
    )
    """
