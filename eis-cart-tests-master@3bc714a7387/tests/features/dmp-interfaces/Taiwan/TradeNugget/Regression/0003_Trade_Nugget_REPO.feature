#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#EISDEV-6582: as part of this jira, new transaction types have been added. fixing ff to change success job count.

@gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3844 @tom_3385 @tw_repo_trades @eisdev_6582 @eisdev_6644
Feature: TW Intraday Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Verify CASH/REPO loaded in DMP

  Scenario: TC1: Clear table data and setup variables and security
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I assign "CashRepo_sm.xml" to variable "SM_INPUT_FILENAME"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('12627-47') AND END_TMS IS NULL;
     COMMIT
    """

    And I execute below query
    """
    UPDATE FT_T_ETID SET END_TMS = SYSDATE
    WHERE EXEC_TRN_ID IN ('12627-47') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """

    And I execute below query and extract values of "PORTFOLIO_NAME" into same variables
     """
     SELECT ACCT_ALT_ID AS PORTFOLIO_NAME FROM ft_t_acid where acct_id_ctxt_typ = 'CRTSID' AND ACCT_ALT_ID like 'TT%'  AND end_tms IS NULL  ORDER  BY 1 DESC
     """

    # End date existing ISIDs to ensure new security created
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BRSF2ZQF6'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BPM23C0G1'"

    And I copy files below from local folder "${testdata.path}/infiles/regression" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SM_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${SM_INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  Scenario: TC2: Load Trades file for  CASH/REPO security transaction in portfolio TT56 (INVNUM=-47)
  Expected Result: 1) File should load and make entry in jblg
  2) Verify a new record created for this transaction and all the required fields are mapped properly in DMP

    Given I assign "CashRepo_transaction_Tem.xml" to variable "INPUT_TEMPLATE_FILENAME"
    Given I assign "CashRepo_transaction.xml" to variable "INPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" with below codes from location "${testdata.path}/infiles"
      |  |  |

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I expect workflow is processed in DMP with success record count as "3"

    # Check if EXTR is created with check TRD_ID, Tran_Type1, TradeDate, Settledate, Trd_CCy, Trd_Price, Trd_Org_Face from test data
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
      FROM FT_T_EXTR
      WHERE TRD_ID = '12627-47' AND   EXEC_TRN_CAT_TYP = 'CMAT' AND TO_CHAR (TRD_DTE, 'MM/DD/YYYY') = '11/27/2018'
      AND TO_CHAR (SETTLE_DTE, 'MM/DD/YYYY') = '12/04/2018'
      AND TRD_CURR_CDE = 'TWD' AND TRD_CPRC = '100.0000000000' AND  TRN_CDE = 'BRSEOD' AND TRD_CQTY = '-1000000.0000000000' AND END_TMS IS NULL
      """

    # Check if EXST is created with data present in the test file(TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'NEWM' AND   GEN_CNT = 2
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '12627-47' AND  END_TMS IS NULL
      )
      """

    # Check if ETCL is created with data present in the test file((TRAN_TYPE_DERIV,TRD_FLAGS,TRAN_TYPE)
    And I expect value of column "ETCL_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS ETCL_PROCESSED_ROW_COUNT FROM FT_T_ETCL
      WHERE INDUS_CL_SET_ID IN ('BRSTRNDERI', 'BRSTRTYP', 'BRSTRDFLAG')
      AND CL_VALUE IN ('Trade','CMAT','X')
      AND  EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '12627-47' AND END_TMS IS NULL
      )
      """

    # Check if ETRP is created with data present in the test file (REPO_RATE, EFF_TERM_DATE)
    And I expect value of column "ETRP_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT (1) AS ETRP_PROCESSED_ROW_COUNT
      FROM FT_T_ETRP
      WHERE REPO_CRTE = '2951236' AND   TO_CHAR (REPO_CLOSE_SETTLE_DTE, 'DD/MM/YY') = '27/11/18' AND EXEC_TRD_ID IN (SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '12627-47' AND  END_TMS IS NULL)
      """

    # Check if TTRL is created with data present in the test file (ORG_INVNUM)
    And I expect value of column "TTRL_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT (1) AS TTRL_PROCESSED_ROW_COUNT
      FROM FT_T_TTRL
      WHERE TTRL_RL_TYP = 'PARENT' AND   EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND   EXEC_TRN_ID = '-45' AND PRNT_EXEC_TRD_ID IN (SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '12627-47' AND  END_TMS IS NULL)
      """