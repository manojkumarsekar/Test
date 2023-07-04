@tom_3700 @001_brs_webservice_url @cis_op_regression @cis_op_brsapi

Feature: CISOrderPlacement | BRS API | F001 | Test BRS Webservice URL in Publish Document workflow
  Test the Publish document workflow with right and wrong BRS API

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "001_002_esi_orders_BRSAPI.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORDNUM"
    And I assign "90" to variable "workflow.max.polling.time"
    And I assign "https://eastspring.blackrock.com/api/reference-data/securities/v1/security-master/wrong" to variable "brswebservice.wrongurl"

  Scenario: TC_1: Load order and Run publish document with correct BRS API url and Credentials
  Expected Result: Workflow should pass the BRS API call

    #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    ${TESTDATA_PATH}/order/sql/UPDATE_ORDER.sql
    """

  #Load Data
    When I copy files below from local folder "${TESTDATA_PATH}/order/testdata/BRSInsightAPI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS |

  #Verify Order data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
     ${TESTDATA_PATH}/order/sql/VERIFY_BRSORDERSTATUS.sql
    """

    When I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}             |
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
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${BRS_JOB_ID}' AND TASK_SUCCESS_CNT =1
      """
     #waiting intentionally
    And I pause for 30 seconds

  Scenario: TC_2: Run publish document with wrong BRS API url and right credentials
  Expected Result: Workflow should fail the BRS API call instance in JBLG and write in NTEL

    #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    ${TESTDATA_PATH}/order/sql/UPDATE_ORDER.sql
    """

  #Load Data
    When I copy files below from local folder "${TESTDATA_PATH}/order/testdata/BRSInsightAPI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS |

  #Verify Order data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
     ${TESTDATA_PATH}/order/sql/VERIFY_BRSORDERSTATUS.sql
    """

    When I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.wrongurl}               |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}             |
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
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${BRS_JOB_ID}' AND TASK_SUCCESS_CNT =0
      """

    And I expect value of column "NTEL_RECORD_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_RECORD_COUNT FROM gs_gc.ft_t_ntel WHERE last_chg_trn_id IN (SELECT trn_id FROM gs_gc.ft_t_trid WHERE JOB_ID = '${BRS_JOB_ID}')
      And NOTFCN_STAT_TYP='OPEN'
      AND MSG_SEVERITY_CDE =50
      AND PARM_VAL_TXT like '%security-master/wrong%'
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory