#Feature History
#TOM-3768: Created New Feature file to test "Request Replay for Bloomberg BVAL OTC Per Security" workflow

@dmp_smoke @bbbvalotcpersecurity @tom_3768 @rr @tom_2426

Feature: GC Smoke | Orchestrator | ESI | Request Replay | Bloomberg | BVAL OTC Per Security

  Scenario: Verify Execution of Workflow with all parameters

    Given I assign "tests/test-data/dmp-gs/gswf/EIS_Bloomberg" to variable "testdata.path"
    And I assign "tests/test-data/dmp-gs/REQUEST_REPLY/SQL" to variable "sql.path"
    And I assign "gs_otcbval_response_template.out" to variable "RESPONSE_TEMPLATENAME"
    And I assign "/dmp/out/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/in/bloomberg" to variable "BB_UPLOAD_DIR"

    #This is to generate the response filename which is driven by database sequence
    And I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """
    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_OTCBVALPrice'
        """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
    # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_otcbval_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "BB_DOWNLOAD_DIR" to "${BB_DOWNLOAD_DIR}"
    And I set the workflow template parameter "BB_UPLOAD_DIR" to "${BB_UPLOAD_DIR}"
    And I set the workflow template parameter "FILE_SYSTEM" to "filesystem/sftp/bloomberg/persecuritysftplegacy"
    And I set the workflow template parameter "FIRM_NAME" to "dl302731"
    And I set the workflow template parameter "IDENTIFIERS" to "PORTFOLIO=BVALOTC:'Eastspring_Loans'"
    And I set the workflow template parameter "REQUEST_TYPE" to "EIS_OTCBVALPrice"
    And I set the workflow template parameter "SN" to "191305"
    And I set the workflow template parameter "USER_NUMBER" to "3650834"
    And I set the workflow template parameter "WORK_STATION" to "0"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_BloombergBVALOTCPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_BloombergBVALOTCPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_otcbval${SEQ}.req |

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
      """
      ${sql.path}/BBValOTC_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Verify Execution of Workflow without mandatory parameters

    Given I assign "tests/test-data/dmp-gs" to variable "testdata.path"
    And I assign "gs_otcbval_response_template.out" to variable "RESPONSE_TEMPLATENAME"

    #This is to generate the response filename which is driven by database sequence
    And I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """
    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_OTCBVALPrice'
        """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
    # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/gswf/EIS_Bloomberg" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_otcbval_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "BB_DOWNLOAD_DIR" to "${BB_DOWNLOAD_DIR}"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_BloombergBVALOTCPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_BloombergBVALOTCPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"

    And I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${testdata.path}/REQUEST_REPLY/BLOOMBERG/BBOTCValPerSec_Missing_Mandatory_Param_ExpectedResult.txt" and reference CSV file "testout/evidence/gswf/resp/asyncResponse.xml" should be successful and exceptions to be written to "${testdata.path}/REQUEST_REPLY/BLOOMBERG/001_bbOtcVALPerSecurity_exceptions_${recon.timestamp}.csv" file

