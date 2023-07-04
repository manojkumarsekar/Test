#Feature History
#TOM-3768: Created New Feature file to test "Request Replay for Cetrel Per Security" workflow
#https://jira.pruconnect.net/browse/EISDEV-7156 : Suppress Exceptions

@dmp_smoke @cetrelpersecurity @tom_3768 @rr @tom_2426 @dmp_gs_upgrade @eisdev_7156
Feature: GC Smoke | Orchestrator | ESI | Request Replay | Cetrel | Per Security

  Scenario: Verify Execution of Workflow with all parameters

    Given I assign "tests/test-data/dmp-gs/gswf/EIS_Cetrel" to variable "testdata.path"
    And I assign "tests/test-data/dmp-gs/REQUEST_REPLY/SQL" to variable "sql.path"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "UCIO.EODS_RESPONSE_TEMPLATE.CETSECPROD.PAMPROD" to variable "RESPONSE_TEMPLATENAME"
    And I assign "UCII.EOD_20100714_140536226.PAMPROD.CETSECPROD" to variable "request.file"

    And I assign "/dmp/out/cetrel" to variable "CET_DOWNLOAD_DIR"
    And I assign "/dmp/in/cetrel" to variable "CET_UPLOAD_DIR"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${CET_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${CET_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME}" as "${CET_DOWNLOAD_DIR}/UCIO.EODS_${VAR_SYSDATE}_161011691.CETSECPROD.PAMPROD" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "CETREL_DOWNLOAD_DIRECTORY" to "${CET_DOWNLOAD_DIR}"
    And I set the workflow template parameter "CETREL_UPLOAD_DIRECTORY" to "${CET_UPLOAD_DIR}"
    And I set the workflow template parameter "CETREL_TIMEOUT" to "3000"
    And I set the workflow template parameter "FIRM_NAME" to "EIS"
    And I set the workflow template parameter "REQUEST_TYPE" to "EIS_Cetrel"
    And I set the workflow template parameter "FILEON_LOCAL" to "false"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CetrelPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CetrelPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 360 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${CET_UPLOAD_DIR}" after processing:
      | ${request.file} |

    #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
    """
    ${sql.path}/CETREL_VerifyAllWorkflowStatus_DONE.sql
    """

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """