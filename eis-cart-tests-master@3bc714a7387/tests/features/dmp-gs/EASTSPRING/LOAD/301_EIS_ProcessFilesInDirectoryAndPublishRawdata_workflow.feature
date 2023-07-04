#Feature History
#TOM-3768: Created New Feature file to Sanity test "Process Files In Directory and Publish Raw Data" workflow

@dmp_smoke @pfl_prd_wf @tom_3768
Feature: GC Smoke | Orchestrator | ESI | Load | Process Files In Directory and Publish Raw Data

  Scenario: Verify Execution of Workflow

  #Assign Variables
    Given I assign "tests/test-data/dmp-gs/CETREL" to variable "TESTDATA_PATH"
    And I assign "test_UCIO.ONDS_20180612_060117605.CETSECPROD.PAMPROD" to variable "INPUT_FILENAME"

    And I set the workflow template parameter "DIRECTORY" to "/dmp/in/cetrel/intraday"
    And I set the workflow template parameter "EMAIL_ADDRESSES" to "zalak.trivedi@eastspring.com"
    And I set the workflow template parameter "EMAIL_FOOTER_TEMP" to "Regards DMP Support"
    And I set the workflow template parameter "EMAIL_HEADER_TEMP" to "Hi Team, Please find attached CETREL Intraday Response file with UCITS Article and Eligibility Flag"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "CETREL Intraday Response File"
    And I set the workflow template parameter "FROM_EMAIL_ADDRESS" to "eis-dmp-support@eastspring.com"
    And I set the workflow template parameter "INPUT_POSITION" to "1,2,3"
    And I set the workflow template parameter "INPUT_SEPARATOR" to "|"
    And I set the workflow template parameter "MESSAGE_BULK_SIZE" to "500"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_CETREL_SECURITY"
    And I set the workflow template parameter "NR_OF_FILES_PARALLEL" to "2"
    And I set the workflow template parameter "OUTPUT_DIRECTORY" to "/dmp/archive/in/cetrel/intraday"
    And I set the workflow template parameter "RAW_FILE_REQUIRED" to "true"
    And I set the workflow template parameter "RAW_HEADER" to "ISIN|UCITS_FLAG|UCITS_ARTICLE"
    And I set the workflow template parameter "REPROCESS_PROCESSED_FILES" to "true"
    And I set the workflow template parameter "RECURSIVE" to "false"
    And I set the workflow template parameter "SORT_ASCENDING" to "true"

    #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/cetrel/intraday/":
      | ${INPUT_FILENAME} |

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ProcessFilesInDirectoryAndPublishRawdata/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ProcessFilesInDirectoryAndPublishRawdata/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 40 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """