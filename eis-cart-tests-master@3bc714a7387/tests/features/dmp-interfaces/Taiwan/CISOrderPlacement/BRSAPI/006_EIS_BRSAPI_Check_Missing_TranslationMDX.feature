@tom_3700 @006_brs_api_transaction_mdx @cis_op_regression @cis_op_brsapi

Feature: CISOrderPlacement | BRS API | F006 |Test Publish Document workflow throw error when translation mdx parameter is missing

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "001_002_esi_orders_BRSAPI.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORDNUM"
    And I assign "90" to variable "workflow.max.polling.time"

  Scenario: TC_1: Run publish document with missing Translation MDX parameter
  Expected Result: Workflow should fail and Instance ID will be generated and job will keep on running in started status in WFRI table

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

    And I set the workflow template parameter "SUBSCRIPTION_NAME" to "EITW_DMP_TO_TW_ORDER_PLACE_SUB"
    And I set the workflow template parameter "INSIGHT_WEBSERVICE_URL" to "${gs.is.order.WORKFLOW.url}"
    And I set the workflow template parameter "INSIGHT_PROPERTY_FILE_LOCATION" to "${insightcredentials.validfilelocation}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_SECURITY_NEW"
    And I set the workflow template parameter "DERIVE_STATUS_EVENTNAME" to "EIS_TWDeriveOrderStatus"
    And I set the workflow template parameter "TRANSLATION_MDX" to ""
    And I set the workflow template parameter "BRS_WEBSERVICE_URL" to "${brswebservice.url}"
    And I set the workflow template parameter "BRSPROPERTY_FILE_LOCATION" to "${brscredentials.validfilelocation}"

    When I send a web service request using template file "tests/test-data/dmp-interfaces/Process_Files/template/PublishDocument/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    And I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/dmp-interfaces/Process_Files/template/PublishDocument/flowResultIdQuery.xpath" to variable "flowResultId"
      #Workflow Verifications
    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "STARTED":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "true"

    And I execute below query
    """
    UPDATE FT_WF_WFRI
    SET WF_RUNTIME_STAT_TYP = 'FAILED'
    WHERE INSTANCE_ID = '${flowResultId}';
    COMMIT
    """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory