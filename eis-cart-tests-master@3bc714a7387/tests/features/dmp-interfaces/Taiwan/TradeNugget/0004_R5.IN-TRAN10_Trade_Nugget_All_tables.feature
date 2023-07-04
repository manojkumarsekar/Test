#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades

@tom_3844 @trades_all_tables @tom_3385
Feature: Inbound Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Verify all tables

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Load files to verify data in EXTR and all child tables

    Given I assign "tc_1_valid_trade.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID IN ('3204-2776_valid_trade', '3204-2776_valid_trade_parent') AND END_TMS IS NULL
    """

    And I execute below query
    """
    UPDATE FT_T_ETID SET END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE EXEC_TRN_ID IN ('3204-2776_valid_trade', '3204-2776_valid_trade_parent') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0004" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check failed Count to see if job was success
    Then I expect value of column "TASK_FAILED_CNT" in the below SQL query equals to "0":
      """
      SELECT TASK_FAILED_CNT FROM FT_T_JBLG WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}') WHERE R=1)
      """

  Scenario: TC_2: Data verification EXTR, ETAM, ETID

    # Check if EXTR is created with data present in the test file
    Then I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/EXTR_Processed_Row_Count.sql
      """

    # Check if ETAM is created with data present in the test file
    Then I expect value of column "ETAM_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/ETAM_Processed_Row_Count.sql
      """

    # Check if ETID is created with data present in the test file
    Then I expect value of column "ETID_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      ${testdata.path}/sql/ETID_Processed_Row_Count.sql
      """

    # Check if EXST is created with data present in the test file
    Then I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/EXST_Processed_Row_Count.sql
      """

    # Check if ETAG is created with data present in the test file
    Then I expect value of column "ETAG_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/ETAG_Processed_Row_Count.sql
      """

    # Check if TRCP is created with data present in the test file
    Then I expect value of column "TRCP_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/TRCP_Processed_Row_Count.sql
      """

    # Check if ETCM is created with data present in the test file
    Then I expect value of column "ETCM_PROCESSED_ROW_COUNT" in the below SQL query equals to "11":
      """
      ${testdata.path}/sql/ETCM_Processed_Row_Count.sql
      """

    # Check if ETCL is created with data present in the test file
    Then I expect value of column "ETCL_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
      """
      ${testdata.path}/sql/ETCL_Processed_Row_Count.sql
      """

     # Check if EXMB is created with data present in the test file
    Then I expect value of column "EXMB_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/EXMB_Processed_Row_Count.sql
      """

    # Check if EXFI is created with data present in the test file
    Then I expect value of column "EXFI_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/EXFI_Processed_Row_Count.sql
      """

    # Check if EXFX is created with data present in the test file
    Then I expect value of column "EXFX_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/EXFX_Processed_Row_Count.sql
      """

    # Check if ETRP is created with data present in the test file
    Then I expect value of column "ETRP_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/ETRP_Processed_Row_Count.sql
      """

    # Check if TTRL is created with data present in the test file
    Then I expect value of column "TTRL_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/TTRL_Processed_Row_Count.sql
      """

    # Check if ETPY is created with data present in the test file
    Then I expect value of column "ETPY_PROCESSED_ROW_COUNT" in the below SQL query equals to "5":
      """
      ${testdata.path}/sql/ETPY_Processed_Row_Count.sql
      """
	  
	# Check if EXIN is created with data present in the test file
    Then I expect value of column "EXIN_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      ${testdata.path}/sql/EXIN_Processed_Row_Count.sql
      """  