@tom_3700 @004_brs_api_shell_security @cis_op_regression @cis_op_brsapi

Feature: CISOrderPlacement | BRS API | F004 |Test Publish Document workflow with shell security in orders file

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "004_esi_orders_ShellSecurityOrders.xml" to variable "INPUT_FILENAME"

    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252641_Shell']/../CUSIP" to variable "BCUSIP1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252642_Shell']/../CUSIP" to variable "BCUSIP2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252643_Shell']/../CUSIP" to variable "BCUSIP3"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252644_Shell']/../CUSIP" to variable "BCUSIP4"

    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252641_Shell']/../ORD_NUM" to variable "ORDNUM1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252642_Shell']/../ORD_NUM" to variable "ORDNUM2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252643_Shell']/../ORD_NUM" to variable "ORDNUM3"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252644_Shell']/../ORD_NUM" to variable "ORDNUM4"

    And I assign "90" to variable "workflow.max.polling.time"

    #end date security to replicate shell security scenarios(The security which is not already present in DMP and Orders file will create this.
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP1}','${BCUSIP2}','${BCUSIP3}','${BCUSIP4}'"

  Scenario: TC_1: Load order with shell security cusip for only Money TrustID, only JP FUND ID, both the IDs and the for none of them and Run publish document
  Expected Result: 4 Securities should be created in ISID for without MoneyTrustID and JP CODE as security created from Orders file
  Orders should be created in AUOR table (4 orders)
  BRS API call is success without any issue in NTEL and update IDID with MoneyTrustID and JP id for respective security

    #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN('${ORDNUM1}','${ORDNUM2}','${ORDNUM3}','${ORDNUM4}')AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

  #Load Data
    When I copy files below from local folder "${TESTDATA_PATH}/order/testdata/BRSInsightAPI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS |

  #Verify Order data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN('${ORDNUM1}','${ORDNUM2}','${ORDNUM3}','${ORDNUM4}')
    AND AOST.ORDER_STAT_TYP = 'ACTIVE'
    """

    And I expect value of column "ISID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ISID_COUNT from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP1}','${BCUSIP2}','${BCUSIP3}','${BCUSIP4}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
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

    Then I execute below query and extract values of "BRS_JOB_ID" into same variables
      """
      SELECT JOB_ID AS BRS_JOB_ID from ft_t_jblg WHERE INSTANCE_ID = '${flowResultId}' AND JOB_CONFIG_TXT='BRS API Call Job'
      """

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${BRS_JOB_ID}' AND TASK_SUCCESS_CNT =4
      """

  Scenario: TC_2: Verify BRS API Request for security which is present in DMP without MoneyTrustID and after getting the response update the ISID table with Money trust ID
    And I expect value of column "ISID_TYPE" in the below SQL query equals to "TWMNYTRST":
      """
      SELECT ID_CTXT_TYP AS ISID_TYPE from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP1}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
      """

  Scenario: TC_3: Verify BRS API Request for security which is present in DMP without JPMFUNDCODE and after getting the response update the ISID table with JPMFUNDCODE
    And I expect value of column "ISID_TYPE" in the below SQL query equals to "TWJPMFNDCDE":
      """
      SELECT ID_CTXT_TYP AS ISID_TYPE from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP3}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
      """

  Scenario: TC_4: Verify BRS API Request for security which is present in DMP which does not have  MoneyTrustID and JPMFundCode setup in Aladdin
    And I expect value of column "ISID_TYPE" in the below SQL query equals to "BCUSIP":
      """
      SELECT ID_CTXT_TYP AS ISID_TYPE from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP4}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE','BCUSIP')
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory