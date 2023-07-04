#Feature History
#TOM-3768: Created New Feature file to test "Request Replay for ICE Per Security" workflow

@dmp_smoke @icepersecurity @tom_3768 @rr @tom_2426

Feature: GC Smoke | Orchestrator | ESI | Request Replay | ICE | Per Security

  Scenario: Assign Variables
    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-gs/gswf/EIS_ICE" to variable "testdata.path"
    And I assign "tests/test-data/dmp-gs/REQUEST_REPLY/SQL" to variable "sql.path"
    And I assign "ICEBPAM_ESI_PRICE_REF_TEMPLATE.csv" to variable "RESPONSE_INPUT_TEMPLATENAME"
    And I assign "ESI_ICEBPAM_REQUEST_${VAR_SYSDATE}.csv" to variable "request.file"
    And I assign "ICEBPAM_ESI_PRICE_REF.csv" to variable "response.file"
    And I assign "/dmp/out/icebpam" to variable "ICE_DOWNLOAD_DIR"
    And I assign "/dmp/in/icebpam" to variable "ICE_UPLOAD_DIR"

  Scenario: Verify Execution of Workflow with all parameters
    Given I create input file "${response.file}" using template "${RESPONSE_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | POS_DATE | DateTimeFormat:YYYYMMdd |

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to ICE for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${ICE_DOWNLOAD_DIR}":
      | ${response.file} |

    And I rename file "${ICE_DOWNLOAD_DIR}/${response.file}" as "${ICE_DOWNLOAD_DIR}/ICEBPAM_ESI_PRICE_REF_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    And I process ICEPerSecurity workflow with below parameters and wait for the job to be completed
      | ICE_DOWNLOAD_DIRECTORY          | ${ICE_DOWNLOAD_DIR} |
      | ICE_TIMEOUT                     | 300                 |
      | ICE_UPLOAD_DIRECTORY            | ${ICE_UPLOAD_DIR}   |
      | MAX_REQUESTS_PER_FILE           | 100000              |
      | PRICE_POINT_EVENT_DEFINITION_ID | ESIPRPTEOD          |
      | REQUEST_TYPE                    | EIM_ICERefdata      |
      | REQUESTOR_ID                    | EIM                 |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${ICE_UPLOAD_DIR}" after processing:
      | ESI_ICEBPAM_REQUEST_${VAR_SYSDATE}.csv |

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
        """
           ${sql.path}/ICE_VerifyAllWorkflowStatus_DONE.sql
        """

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Verify Execution of Workflow without mandatory parameters

    Given I assign "tests/test-data/dmp-gs" to variable "testdata.path"

    And I create input file "${response.file}" using template "${RESPONSE_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/gswf/EIS_ICE"
      | POS_DATE | DateTimeFormat:YYYYMMdd |

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to ICE for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/gswf/EIS_ICE/testdata" to the host "dmp.ssh.inbound" folder "${ICE_DOWNLOAD_DIR}":
      | ${response.file} |

    And I rename file "${ICE_DOWNLOAD_DIR}/${response.file}" as "${ICE_DOWNLOAD_DIR}/ICEBPAM_ESI_PRICE_REF_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "ICE_DOWNLOAD_DIRECTORY" to "${ICE_DOWNLOAD_DIR}"
    And I set the workflow template parameter "ICE_UPLOAD_DIRECTORY" to "${ICE_UPLOAD_DIR}"
    And I set the workflow template parameter "ICE_TIMEOUT" to "300"
    And I set the workflow template parameter "MAX_REQUESTS_PER_FILE" to "100000"
    And I set the workflow template parameter "PRICE_POINT_EVENT_DEFINITION_ID" to "ESIPRPTEOD"
    And I set the workflow template parameter "REQUESTOR_ID" to "EIM"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ICEPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    And I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ICEPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"
    And I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${testdata.path}/ICE/ICEPerSec_Missing_Mandatory_Param_ExpectedResult.txt" and reference CSV file "testout/evidence/gswf/resp/asyncResponse.xml" should be successful and exceptions to be written to "${testdata.path}/ICE/001_icePerSecurity_exceptions_${recon.timestamp}.csv" file


  Scenario: Verify Execution of EIS_ICEPerSecurity Workflow with only mandatory parameters

    Given I assign "tests/test-data/dmp-gs/gswf/EIS_ICE" to variable "testdata.path"
    And I create input file "${response.file}" using template "${RESPONSE_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | POS_DATE | DateTimeFormat:YYYYMMdd |

  # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
  # Since, we are not connecting to ICE for testing this is to simulate the process of request reply
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${ICE_DOWNLOAD_DIR}":
      | ${response.file} |

    And I rename file "${ICE_DOWNLOAD_DIR}/${response.file}" as "${ICE_DOWNLOAD_DIR}/ICEBPAM_ESI_PRICE_REF_1_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "REQUEST_TYPE" to "EIM_ICERefdata"
    And I set the workflow template parameter "ICE_TIMEOUT" to "3000"
    And I set the workflow template parameter "MAX_REQUESTS_PER_FILE" to "100000"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ICEPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    And I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ICEPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "STARTED":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"
    And I poll for maximum 60 seconds and expect the result of the SQL query below equals to "3":
          """
            SELECT Count(*) as RECORD_COUNT
            FROM
              (SELECT INSTANCE_ID
              FROM
                (SELECT INSTANCE_ID
                FROM
                  (SELECT WFRI.INSTANCE_ID,
                    TOKN1.INSTANCE_ID PRNT_INSTANCE_ID
                  FROM FT_WF_WFRI WFRI
                  LEFT JOIN FT_WF_TOKN TOKN1
                  ON (WFRI.PRNT_TOKEN_ID = TOKN1.TOKEN_ID)
                  JOIN FT_WF_WFDF WFDF USING (WORKFLOW_ID)
                  ) IVIEW
                  CONNECT BY PRIOR INSTANCE_ID = PRNT_INSTANCE_ID
                  START WITH PRNT_INSTANCE_ID  = '${flowResultId}'
                UNION
                SELECT INSTANCE_ID
                FROM FT_WF_WFRI WFRI
                WHERE WFRI.INSTANCE_ID = '${flowResultId}'
                )
              ) INSTANCE_ID,
              FT_WF_WFRI WFRI, FT_WF_WFDF WFDF
            WHERE INSTANCE_ID.INSTANCE_ID = WFRI.INSTANCE_ID
            AND WFRI.WORKFLOW_ID = WFDF.WORKFLOW_ID
            AND WFDF.WORKFLOW_NME in ('EIS_RequestReply','EIS_SplitRequests','EIS_ICEPerSecurity')
            AND WFRI.WF_RUNTIME_STAT_TYP = 'STARTED'
        """
    And I execute below query
    """
    UPDATE FT_T_JBLG
    SET job_stat_typ = 'CLOSED'
    WHERE INSTANCE_ID = '${flowResultId}';
    COMMIT
    """

    And I execute below query
    """
    UPDATE FT_WF_WFRI
    SET WF_RUNTIME_STAT_TYP = 'FAILED'
    WHERE INSTANCE_ID = '${flowResultId}';
    COMMIT
    """