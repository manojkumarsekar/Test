#https://jira.intranet.asia/browse/TOM-4289

@tom_4289
Feature: Mapping of pending fields for Taiwan settlement Instruction - BCUSIP2 where Code =9, TRD_COUPON, TRD_PURPOSE and BROKER_REASON

# TC 1 - To check that new mapped fields are populated properly in DMP
  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('4289-4289')
     AND END_TMS IS NULL;
	 UPDATE FT_T_ETID SET END_TMS = SYSDATE
     WHERE EXEC_TRN_ID IN ('4289-4289')
     AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     UPDATE FT_T_ISID SET ISS_ID='TEST_4289_OLD'
     WHERE ISS_ID IN ('TEST_4289')
     AND ID_CTXT_TYP = 'RPN' AND END_TMS IS NULL;
     COMMIT
    """

  Scenario: Load Trades file for portfolio TEST_4289 where new fields coming with values
  Expected Result: 1) File should load and make entry in jblg

    Given I assign "4289_sm.xml" to variable "INPUT_SM_FILENAME1"
    And I assign "4289_Transaction.xml" to variable "INPUT_TRANSACTION_FILENAME1"
    And I assign "90" to variable "workflow.max.polling.time"

    And I copy files below from local folder "${testdata.path}/infiles/0011" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_SM_FILENAME1}          |
      | ${INPUT_TRANSACTION_FILENAME1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_SM_FILENAME1}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='1'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_TRANSACTION_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='1'
      """

  Scenario: Verification of loaded data in DMP
  Expected Result: 1) Verify a new record created for this transaction and all the required fields are mapped properly in DMP

     # Check if ISID is created with check BCUSIP2 Code = 9 (RPN) identifier from test data
    And I expect value of column "ISID_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISID_PROCESSED_ROW_COUNT
      FROM FT_T_ISID
      WHERE ISS_ID = 'TEST_4289' AND ID_CTXT_TYP = 'RPN' AND END_TMS IS NULL
      """

 # Check if EXTR is created with check TRD_PURPOSE from test data
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
      FROM FT_T_EXTR
      WHERE TRD_ID = '4289-4289' AND TRD_PURP_TYP = 'N_P RENOIN' AND END_TMS IS NULL
      """

    # Check if ETCL is created with data present in the test file(BROKER_REASON)
    And I expect value of column "ETCL_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ETCL_PROCESSED_ROW_COUNT FROM FT_T_ETCL
      WHERE INDUS_CL_SET_ID IN ('BRSBROKRES') AND CL_VALUE = 'DN'
      AND  EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID IN ('4289-4289') AND END_TMS IS NULL
      )
      """

 # Check if EXFI is created with data present in the test file(TRD_YIELD,TRD_YIELD_TO_CALL,TRD_DIRTY_PRICE)
    And I expect value of column "EXFI_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXFI_PROCESSED_ROW_COUNT FROM FT_T_EXFI
      WHERE CRRNT_YLD_CPCT = '1.1000000000' AND WORST_YIELD_CPCT = '2.2000000000' AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4289-4289' AND END_TMS IS NULL
      )
      """

# TC 2 - To check update of values
  Scenario: Load Trades file for portfolio TEST_4289 where new fields coming with values
  Expected Result: 1) File should load and make entry in jblg

    Given I assign "4289_sm_update.xml" to variable "INPUT_SM_FILENAME2"
    And I assign "4289_Transaction_update.xml" to variable "INPUT_TRANSACTION_FILENAME2"

    And I copy files below from local folder "${testdata.path}/infiles/0011" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_SM_FILENAME2}          |
      | ${INPUT_TRANSACTION_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_SM_FILENAME2}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='1'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_TRANSACTION_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='1'
      """

  Scenario: Verification of updated values for loaded data in DMP
  Expected Result: 1) Verify a exisitng records updated for this transaction properly in DMP

       # Check if ISID is updated with check BCUSIP2 Code = 9 (RPN) identifier from test data
    And I expect value of column "ISID_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISID_PROCESSED_ROW_COUNT
      FROM FT_T_ISID
      WHERE ISS_ID = 'TEST_4289_1' AND ID_CTXT_TYP = 'RPN' AND END_TMS IS NULL
      """

   # Check if EXTR is updated with check TRD_PURPOSE from test data
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
      FROM FT_T_EXTR
      WHERE TRD_ID = '4289-4289' AND TRD_PURP_TYP = 'HF.RED' AND END_TMS IS NULL
      """

       # Check if EXFI is updated with data present in the test file(TRD_YIELD,TRD_YIELD_TO_CALL,TRD_DIRTY_PRICE)
    And I expect value of column "EXFI_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXFI_PROCESSED_ROW_COUNT FROM FT_T_EXFI
      WHERE CRRNT_YLD_CPCT = '3.3000000000' AND WORST_YIELD_CPCT = '4.4000000000' AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4289-4289' AND END_TMS IS NULL
      )
      """

      # Check if ETCL is updated with data present in the test file(BROKER_REASON)
    And I expect value of column "ETCL_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ETCL_PROCESSED_ROW_COUNT FROM FT_T_ETCL
      WHERE INDUS_CL_SET_ID IN ('BRSBROKRES') AND CL_VALUE = 'EN'
      AND  EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID IN ('4289-4289') AND END_TMS IS NULL
      )
      """

# TC 3 - To check warning raised for missing value in IDMV
  Scenario: Load Trades file for portfolio TEST_4289 where new fields coming with values
  Expected Result: 1) File should load and make entry in jblg

    Given I assign "4289_Transaction_warning_30.xml" to variable "INPUT_TRANSACTION_FILENAME3"

    And I copy files below from local folder "${testdata.path}/infiles/0011" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_TRANSACTION_FILENAME3} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_TRANSACTION_FILENAME3}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID3}' and TASK_SUCCESS_CNT ='1'
      """

  Scenario: Verification of warning raised for loaded data in DMP
  Expected Result: 1) Verify a new record created for this transaction  with null value in EXTR.TRD_PURP_TYP and WARNING raised in TRID for missing IDMV

      #Throw Warning if IDMV is missing for TRD_PURPOSE
    Then I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS NTEL_VALID_COUNT FROM FT_T_NTEL
        WHERE NOTFCN_STAT_TYP = 'OPEN'
        AND NOTFCN_ID = 262
        AND MSG_SEVERITY_CDE = 30
        AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID3}')
        AND PARM_VAL_TXT LIKE '%ABCD%'
        """

     # Check if EXTR is created with null value id TRD_PUPR_TYP as  TRD_PURPOSE is missing in IDMV
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
      FROM FT_T_EXTR
      WHERE TRD_ID = '4289-4289' AND TRD_PURP_TYP IS NULL AND END_TMS IS NULL
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory