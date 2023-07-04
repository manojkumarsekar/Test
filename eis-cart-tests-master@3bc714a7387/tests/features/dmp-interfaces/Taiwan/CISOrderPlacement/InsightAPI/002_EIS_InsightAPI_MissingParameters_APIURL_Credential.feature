@tom_3700 @002_insight_missing_parameters @cis_op_regression @cis_op_insightapi

Feature: CISOrderPlacement | Insight API | F002 | Test Publish Document workflow with missing Insight API and Credentials parameters
  Test the Publish document workflow with missing BRS details INSIGHT_WEBSERVICE_URL and INSIGHT_PROPERTY_FILE_LOCATION

  Scenario: Setup Variables and clear data

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement" to variable "TESTDATA_PATH"
    And I assign "001_002_esi_orders_BRSAPI.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/BRSInsightAPI/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORDNUM"
    And I assign "90" to variable "workflow.max.polling.time"

  Scenario: TC_1: Run publish document with missing Insight API parameters
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
    And I set the workflow template parameter "INSIGHT_WEBSERVICE_URL" to ""
    And I set the workflow template parameter "INSIGHT_PROPERTY_FILE_LOCATION" to ""
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_SECURITY_NEW"
    And I set the workflow template parameter "DERIVE_STATUS_EVENTNAME" to "EIS_TWDeriveOrderStatus"
    And I set the workflow template parameter "TRANSLATION_MDX" to "${transalationmdx.validfilelocation}"
    And I set the workflow template parameter "BRS_WEBSERVICE_URL" to "${brswebservice.url}"
    And I set the workflow template parameter "BRSPROPERTY_FILE_LOCATION" to "${brscredentials.validfilelocation}"

    When I send a web service request using template file "tests/test-data/dmp-interfaces/Process_Files/template/PublishDocument/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    And I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/dmp-interfaces/Process_Files/template/PublishDocument/flowResultIdQuery.xpath" to variable "flowResultId"
    And I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/output/PublishDocument_MissingInsightParameter.txt" and reference CSV file "testout/evidence/gswf/resp/asyncResponse.xml" should be successful and exceptions to be written to "${TESTDATA_PATH}/output/001_publishDocument_exceptions_${recon.timestamp}.csv" file


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory