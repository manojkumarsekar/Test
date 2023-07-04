@tom_3700 @005_brs_api_update_existing_cdfs @cis_op_regression @cis_op_brsapi

Feature: CISOrderPlacement | BRS API | F005 |Test BRS API is updating existing Money Trust ID and JP Fund code

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "005_esi_orders_ExistingSameCDFAsAladdin.xml" to variable "INPUT_FILENAME"

    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252641_Shell']/../CUSIP" to variable "BCUSIP1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252642_Shell']/../CUSIP" to variable "BCUSIP2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252643_Shell']/../CUSIP" to variable "BCUSIP3"

    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252641_Shell']/../ORD_NUM" to variable "ORDNUM1"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252642_Shell']/../ORD_NUM" to variable "ORDNUM2"
    And I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with xpath "//ORDER//ORD_NUM[text()='2252643_Shell']/../ORD_NUM" to variable "ORDNUM3"

    And I assign "90" to variable "workflow.max.polling.time"

    #Pre-requisite to change the ISS_ID for Money trust ID
    Given I execute below query
	"""
    UPDATE FT_T_ISID SET ISS_ID ='1435'
    where INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID='${BCUSIP1}' AND END_TMS IS NULL)
    AND ID_CTXT_TYP ='TWMNYTRST';
    COMMIT
    """

    #Pre-requisite to change the ISS_ID for JPM Fund code
    Given I execute below query
	"""
    UPDATE FT_T_ISID SET ISS_ID ='EMDAAU'
    where INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID='${BCUSIP3}' AND END_TMS IS NULL)
    AND ID_CTXT_TYP ='TWJPMFNDCDE';
    COMMIT
    """

    And I execute below query and extract values of "MONEY_TD_ID" into same variables
      """
      SELECT ISS_ID AS MONEY_TD_ID from gs_gc.FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from gs_gc.FT_T_ISID WHERE ISS_ID IN ('${BCUSIP1}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP ='TWMNYTRST'
      """

    And I execute below query and extract values of "JP_FUND_ID" into same variables
      """
      SELECT ISS_ID AS JP_FUND_ID from gs_gc.FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from gs_gc.FT_T_ISID WHERE ISS_ID IN ('${BCUSIP3}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP ='TWJPMFNDCDE'
      """

  Scenario: TC_1: Load order with existing DMP cusip for only Money TrustID, only JP FUND ID, both the IDs  with the same value as in Aladin and Run publish document
  Expected Result: 3 Securities should be updated in ISID for MoneyTrustID and JP CODE
  Orders should be created in AUOR table (4 orders)
  BRS API call is success without any issue in NTEL and CHECk IDID with MoneyTrustID and JP id value is same as previous one
  Verify BRS API Request for security which is present in DMP with MoneyTrustID and check there is no change in Money Trust ID
  Verify BRS API Request for security which is present in DMP with JPMFUNDCODE and check there is no change in Money Trust ID

    #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN('${ORDNUM1}','${ORDNUM2}','${ORDNUM3}')AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
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

    Then I execute below query and extract values of "BRS_JOB_ID" into same variables
      """
      SELECT JOB_ID AS BRS_JOB_ID from ft_t_jblg WHERE INSTANCE_ID = '${flowResultId}' AND JOB_CONFIG_TXT='BRS API Call Job'
      """

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${BRS_JOB_ID}' AND TASK_SUCCESS_CNT =3
      """

  #  Verify BRS API Request for security which is present in DMP with MoneyTrustID and check there is no change in Money Trust ID
    And I expect value of column "MONEY_TRUST_AFTER" in the below SQL query equals to "${MONEY_TD_ID}":
      """
      SELECT ISS_ID AS MONEY_TRUST_AFTER from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP1}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
      """

#  Verify BRS API Request for security which is present in DMP with JPMFUNDCODE and check there is no change in Money Trust ID
    And I expect value of column "JP_FUND_AFTER" in the below SQL query equals to "${JP_FUND_ID}":
      """
      SELECT ISS_ID AS JP_FUND_AFTER from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP3}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
      """

  Scenario: TC_2: Load order with existing DMP cusip for only Money TrustID, only JP FUND ID, both the IDs  with the different value as in Aladin and Run publish document
  Expected Result: 3 Securities should be updated in ISID for MoneyTrustID and JP CODE
  Orders should be created in AUOR table (4 orders)
  BRS API call is success without any issue in NTEL and CHECk IDID with MoneyTrustID and JP id value is updated with new value
  Verify BRS API Request for security which is present in DMP with MoneyTrustID and check Money Trust ID updated in ISID
  Verify BRS API Request for security which is present in DMP with JPMFUNDCODE and check JPMFUNDCODE updated in ISID

    #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN('${ORDNUM1}','${ORDNUM2}','${ORDNUM3}')AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

    #Pre-requisite to change the ISS_ID for Money trust ID
    Given I execute below query
	"""
    UPDATE FT_T_ISID SET ISS_ID ='TEST_MONEYID'
    where INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID='${BCUSIP1}' AND END_TMS IS NULL)
    AND ID_CTXT_TYP ='TWMNYTRST';
    COMMIT
    """

    #Pre-requisite to change the ISS_ID for JPM Fund code
    Given I execute below query
	"""
    UPDATE FT_T_ISID SET ISS_ID ='TEST_JPMID'
    where INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID='${BCUSIP3}' AND END_TMS IS NULL)
    AND ID_CTXT_TYP ='TWJPMFNDCDE';
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

    Then I execute below query and extract values of "BRS_JOB_ID" into same variables
      """
      SELECT JOB_ID AS BRS_JOB_ID from ft_t_jblg WHERE INSTANCE_ID = '${flowResultId}' AND JOB_CONFIG_TXT='BRS API Call Job'
      """

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${BRS_JOB_ID}' AND TASK_SUCCESS_CNT =3
      """

  #  Verify BRS API Request for security which is present in DMP with MoneyTrustID and check there is no change in Money Trust ID
    And I expect value of column "MONEY_TRUST_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS MONEY_TRUST_COUNT from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP1}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
      AND ISS_ID IN ('TEST_MONEYID')
      """

#  Verify BRS API Request for security which is present in DMP with JPMFUNDCODE and check there is no change in Money Trust ID
    And I expect value of column "JP_FUND_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS JP_FUND_COUNT from FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID from FT_T_ISID WHERE ISS_ID IN ('${BCUSIP3}') AND END_TMS IS NULL)
      AND ID_CTXT_TYP IN ('TWMNYTRST','TWJPMFNDCDE')
      AND ISS_ID IN ('TEST_JPMID')
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory