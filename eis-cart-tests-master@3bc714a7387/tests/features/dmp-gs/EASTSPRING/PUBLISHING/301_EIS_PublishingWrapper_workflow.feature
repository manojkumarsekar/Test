#Feature History
#TOM-3768: Moved the feature file from as per new folder structure. Updated Feature Description

@dmp_smoke @publishing_wrapper_wf @tom_3768 @tom_4450
Feature: GC Smoke | Orchestrator | ESI | Publishing | Publishing Wrapper

  Background: Assign publishing directory path & Default Publishing wrapper Template params

    Given I assign "/dmp/out/brs/eod" to variable "EXPECTED_PUBLISHING_DIRECTORY"
    And I assign "test_automation_publishing" to variable "FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I set the workflow template parameter "RECORD_TAG" to ""
    And I set the workflow template parameter "JOB_ID" to ""
    And I set the workflow template parameter "MESSAGE_TYPE" to ""
    And I set the workflow template parameter "SQL" to ""
    And I set the workflow template parameter "TRANSACTION_ID" to ""
    And I set the workflow template parameter "UNESCAPE_XML" to "false"
    And I set the workflow template parameter "AOI_PROCESSING" to "false"
    And I set the workflow template parameter "EXTRACT_STREETREF_TO_SUBMIT" to "false"
    And I set the workflow template parameter "XML_MERGE_LEVEL" to "1"
    And I set the workflow template parameter "FOOTER_COUNT" to "0"
    And I set the workflow template parameter "PUBLISHING_BULK_SIZE" to "500"
    And I set the workflow template parameter "COLUMN_SEPARATOR" to ","
    And I set the workflow template parameter "COLUMN_TO_SORT" to "0"

  Scenario: Verify Execution of Workflow - Upon successful execution of publishing job, file should be published in desired location

    #Remove if file is already present (if file with same name present already, the job will fail)
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${EXPECTED_PUBLISHING_DIRECTORY}" if exists:
      | ${FILE_NAME}* |

    Given I set the workflow template parameter "PUBLISHING_FILE_NAME" to "${FILE_NAME}.csv"

    #SUBSCRIPTION_NAME should be available in FT_CFG_SBDF table, if not system throws error
    And I set the workflow template parameter "SUBSCRIPTION_NAME" to "ESII_DMP_TO_BRS_NAV_SCB_SUB"

    When I send a web service request using template file "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "PublishDir" should be "${EXPECTED_PUBLISHING_DIRECTORY}"
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${EXPECTED_PUBLISHING_DIRECTORY}" after processing:
      | ${FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I extract value from the XML file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "pub1OID" to variable "pubID"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT PUB_STATUS FROM FT_CFG_PUB1 WHERE TRUNC(START_TMS) = TRUNC(SYSDATE)
      AND PUB1_OID='${pubID}'
      And PUB_OUT_TXT like '%${FILE_NAME}%.csv'
      """

  Scenario: Verify Execution of Workflow with Same publishing file name - Should throw an exception and Job should fail
  Same file name used in first scenario should be used to make this testcase pass (negative testcase)

    Given I set the workflow template parameter "PUBLISHING_FILE_NAME" to "${FILE_NAME}.csv"
    And I set the workflow template parameter "SUBSCRIPTION_NAME" to "ESII_DMP_TO_BRS_NAV_SCB_SUB"

    When I send a web service request using template file "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 80 seconds and expect the result of the SQL query below equals to "PASS":
    """
    SELECT CASE WHEN COUNT(1)>0 THEN 'PASS' ELSE 'POLL' END FROM FT_WF_TOKN
    WHERE INSTANCE_ID='${flowResultId}'
    AND TOKEN_STAT_TYP = 'FAILED'
    """

    #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "true"

    When I extract value from the XML file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "pub1OID" to variable "pubID"
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${EXPECTED_PUBLISHING_DIRECTORY}" after processing:
      | ${FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "ERROR":
    """
    SELECT PUB_STATUS FROM ft_cfg_pub1 WHERE pub1_oid =
    (
        SELECT substr(variable_val_txt,3) FROM ft_wf_wfrv WHERE variable_id = '${flowResultId}' AND variable_nme = 'pub1OID'
    )
    AND pub_description LIKE 'Old published files still present in the publishing folder'
    """

    And I remove below files in the host "dmp.ssh.inbound" from folder "${EXPECTED_PUBLISHING_DIRECTORY}" if exists:
      | ${FILE_NAME}* |

  Scenario: Verify Execution of Workflow with Incorrect SUBSCRIPTION_NAME - Should throw an exception and Job should fail

    Given I set the workflow template parameter "PUBLISHING_FILE_NAME" to "invalid_publishing.csv"
    And I set the workflow template parameter "SUBSCRIPTION_NAME" to "INVALID"

    When I send a web service request using template file "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "PASS":
    """
    SELECT CASE WHEN COUNT(1)>0 THEN 'PASS' ELSE 'POLL' END FROM FT_WF_TOKN
    WHERE INSTANCE_ID='${flowResultId}'
    AND TOKEN_STAT_TYP = 'FAILED'
    """

    #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "true"

    Then I poll for maximum 40 seconds and expect the result of the SQL query below equals to "ERROR":
    """
    SELECT PUB_STATUS FROM ft_cfg_pub1 WHERE pub1_oid =
    (
        SELECT substr(variable_val_txt,3) FROM ft_wf_wfrv WHERE variable_id = '${flowResultId}' AND variable_nme = 'pub1OID'
    )
    AND pub_description LIKE 'In-correct subscription name INVALID , please verify.%'
    """