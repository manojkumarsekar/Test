@tom_3700 @004_insight_format @cis_op_regression @cis_op_insightapi

Feature: CISOrderPlacement | Insight API | F004 | Test Publish Document workflow for ESUN Portfolio and check format1 called

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "006_esi_orders_ESUN_NONESUN_Portfolio.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format1']/../CUSIP" to variable "BCUSIP1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format2']/../CUSIP" to variable "BCUSIP2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format2_NoACST']/../CUSIP" to variable "BCUSIP3"

    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format1']/../ORD_NUM" to variable "ORDNUM1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format2']/../ORD_NUM" to variable "ORDNUM2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format2_NoACST']/../ORD_NUM" to variable "ORDNUM3"

    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format1']/../ORD_DETAIL_set//ORD_DETAIL//PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format2']/../ORD_DETAIL_set//ORD_DETAIL//PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='225264_Format2_NoACST']/../ORD_DETAIL_set//ORD_DETAIL//PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID3"

    And I assign "90" to variable "workflow.max.polling.time"

  #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN('${ORDNUM1}','${ORDNUM2}','${ORDNUM3}')AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

    #Pre-requisite to set ESUN portfolio
    Given I execute below query
	"""
    DELETE FROM FT_T_ACST
    WHERE  ACCT_ID IN (SELECT ACCT_ID from FT_T_ACID WHERE ACCT_ALT_ID in ('${PORTFOLIOCRTSID1}', '${PORTFOLIOCRTSID2}') AND END_TMS IS NULL)
    AND STAT_DEF_ID='ESUNPLTF';
    COMMIT
    """

    #Pre-requisite to set ESUN portfolio
    Given I execute below query
	"""
    INSERT INTO FT_T_ACST (STAT_ID, STAT_DEF_ID, ACCT_ORG_ID, ACCT_BK_ID, ACCT_ID, START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID, STAT_CHAR_VAL_TXT)
    (SELECT NEW_OID, 'ESUNPLTF', 'EIS', 'EIS', ACCT_ID, SYSDATE, SYSDATE, 'AUTOMATION', 'Y' FROM FT_T_ACID A WHERE ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACCT_ALT_ID = '${PORTFOLIOCRTSID1}' AND END_TMS IS NULL AND NOT EXISTS (SELECT 1 FROM FT_T_ACST WHERE A.ACCT_ID = ACCT_ID AND STAT_DEF_ID = 'ESUNPLTF'
    AND STAT_CHAR_VAL_TXT = 'Y'));
    COMMIT
    """

    #Pre-requisite to set NON ESUN portfolio
    Given I execute below query
	"""
    INSERT INTO FT_T_ACST (STAT_ID, STAT_DEF_ID, ACCT_ORG_ID, ACCT_BK_ID, ACCT_ID, START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID, STAT_CHAR_VAL_TXT)
    (SELECT NEW_OID, 'ESUNPLTF', 'EIS', 'EIS', ACCT_ID, SYSDATE, SYSDATE, 'AUTOMATION', 'N' FROM FT_T_ACID A WHERE ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACCT_ALT_ID = '${PORTFOLIOCRTSID2}' AND END_TMS IS NULL AND NOT EXISTS (SELECT 1 FROM FT_T_ACST WHERE A.ACCT_ID = ACCT_ID AND STAT_DEF_ID = 'ESUNPLTF'
    AND STAT_CHAR_VAL_TXT = 'N'));
    COMMIT
    """

  Scenario: TC_1: Load order with ESUN portfolio and Run publish document and check Fomrat1 is called
  Expected Result: Workflow should pass and Fomrat1 is called by Insight API
  #Load Data
    When I copy files below from local folder "${TESTDATA_PATH}/order/testdata/BRSInsightAPI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS |

  #Verify Order data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN('${ORDNUM1}','${ORDNUM2}','${ORDNUM3}')
    AND AOST.ORDER_STAT_TYP = 'ACTIVE'
    """

    When I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}           |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    Then I execute below query and extract values of "INSIGHT_JOB_ID" into same variables
      """
      SELECT JOB_ID AS INSIGHT_JOB_ID from ft_t_jblg WHERE INSTANCE_ID = '${flowResultId}' AND JOB_CONFIG_TXT='Publish Insight Report Job'
      """

    #  Format1
    And I expect value of column "TRID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS TRID_COUNT FROM ft_t_trid
      WHERE JOB_ID = '${INSIGHT_JOB_ID}'
      AND CRRNT_TRN_STAT_TYP ='CLOSED'
      AND TRN_MSG_STAT_DESC like '${ORDNUM1}_${PORTFOLIOCRTSID1}_${BCUSIP1}_ESUN%'
      """

    #  Format2 with entry in ACST

    Then I execute below query and extract values of "BROKER_NAME" into same variables
      """
      SELECT FINS_ID AS BROKER_NAME from ft_t_fiid
      where INST_MNEM IN
      (select FINR_INST_MNEM from ft_t_ccrf where ACCT_ID IN (SELECT ACCT_ID from FT_T_ACID WHERE ACCT_ALT_ID='${PORTFOLIOCRTSID2}' AND END_TMS IS NULL)
      and INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP2}') AND END_TMS IS NULL))
      and FINS_ID_CTXT_TYP ='BRSTRDCNTCDE'
      """

    And I expect value of column "TRID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS TRID_COUNT FROM ft_t_trid
      WHERE JOB_ID = '${INSIGHT_JOB_ID}'
      AND CRRNT_TRN_STAT_TYP ='CLOSED'
      AND TRN_MSG_STAT_DESC like '${ORDNUM2}_${PORTFOLIOCRTSID2}_${BCUSIP2}_${BROKER_NAME}%'
      """

     #  Format2 without entry in ACST

    Then I execute below query and extract values of "BROKER_NAME" into same variables
      """
      SELECT FINS_ID AS BROKER_NAME from ft_t_fiid
      where INST_MNEM IN
      (select FINR_INST_MNEM from ft_t_ccrf where ACCT_ID IN (SELECT ACCT_ID from FT_T_ACID WHERE ACCT_ALT_ID='${PORTFOLIOCRTSID3}' AND END_TMS IS NULL)
      and INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP3}') AND END_TMS IS NULL))
      and FINS_ID_CTXT_TYP ='BRSTRDCNTCDE'
      """

    And I expect value of column "TRID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS TRID_COUNT FROM ft_t_trid
      WHERE JOB_ID = '${INSIGHT_JOB_ID}'
      AND CRRNT_TRN_STAT_TYP ='CLOSED'
      AND TRN_MSG_STAT_DESC like '${ORDNUM3}_${PORTFOLIOCRTSID3}_${BCUSIP3}_${BROKER_NAME}%'
      """


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory