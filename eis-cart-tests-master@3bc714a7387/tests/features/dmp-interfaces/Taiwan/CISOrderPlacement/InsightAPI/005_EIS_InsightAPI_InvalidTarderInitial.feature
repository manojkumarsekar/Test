@tom_3700 @005_insight_invalid_trader_initial @cis_op_regression @cis_op_insightapi

Feature: CISOrderPlacement | Insight API | F005 |Test Insight Webservice URL in Publish Document workflow with invalid trader initial
  Test the Publish document workflow throw exception for invalid initial

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "007_esi_orders_ESUN_Signature.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORDNUM"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I assign "90" to variable "workflow.max.polling.time"

  Scenario: TC_1: Load order and Run publish document with Invalid initial
  Expected Result: Workflow should pass the Insight API call

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
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}           |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    Then I execute below query and extract values of "INSIGHT_JOB_ID" into same variables
      """
      SELECT JOB_ID AS INSIGHT_JOB_ID from ft_t_jblg WHERE INSTANCE_ID = '${flowResultId}' AND JOB_CONFIG_TXT='Publish Insight Report Job'
      """

    And I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM gs_gc.ft_t_ntel WHERE last_chg_trn_id IN (SELECT trn_id FROM gs_gc.ft_t_trid WHERE JOB_ID = '${INSIGHT_JOB_ID}')
      And NOTFCN_STAT_TYP='OPEN'
      AND MSG_SEVERITY_CDE =50
      AND PARM_VAL_TXT like '%Sign cannot be null%'
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory