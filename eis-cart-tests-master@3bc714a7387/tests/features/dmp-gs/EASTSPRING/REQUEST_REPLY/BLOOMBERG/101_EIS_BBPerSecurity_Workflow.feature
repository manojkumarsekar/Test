#Feature History
#TOM-3768: Created New Feature file to test "Request Replay for Bloomberg Per Security" workflow
@dmp_smoke @bbpersecurity @tom_3768 @rr @tom_2426 @dmp_gs_upgrade
Feature: GC Smoke | Orchestrator | ESI | Request Replay | Bloomberg | Per Security

  Scenario: Assign variables
    Given I assign "tests/test-data/dmp-gs/gswf/EIS_Bloomberg" to variable "testdata.path"
    And I assign "tests/test-data/dmp-gs/REQUEST_REPLY/SQL" to variable "sql.path"
    And I assign "/dmp/out/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/in/bloomberg" to variable "BB_UPLOAD_DIR"

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_Secmaster
    Given I assign "gs_secmaster_response_template.out" to variable "RESPONSE_TEMPLATENAME"

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
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
    # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_secmaster_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Secmaster      |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_secmaster${SEQ}.req |

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
      """
      ${sql.path}/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_Price

    Given I assign "gs_price_response_template.out" to variable "RESPONSE_TEMPLATENAME"

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
        WHERE VND_RQST_TYP = 'EIS_Price'
        """

      # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
      # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_price_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Price          |
      | SN              | 191305             |
      | USER_NUMBER     | 30350268           |
      | WORK_STATION    | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_price${SEQ}.req |

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
      """
      ${sql.path}/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_Creditrisk

    Given I assign "gs_credtrisk_response_template.out" to variable "RESPONSE_TEMPLATENAME"

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
        WHERE VND_RQST_TYP = 'EIS_Creditrisk'
        """

      # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
      # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_credtrisk_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Creditrisk     |
      | SN              | 191305             |
      | USER_NUMBER     | 30350268           |
      | WORK_STATION    | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_credtrisk${SEQ}.req |

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
      """
      ${sql.path}/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_CashBVALPrice

    Given I assign "gs_cashbval_response_template.out" to variable "RESPONSE_TEMPLATENAME"
    And I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """
    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_CashBVALPrice'
        """
    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_cashbval_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_CashBVALPrice  |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_cashbval${SEQ}.req |

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
      """
      ${sql.path}/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Verify Execution of Workflow without mandatory parameters
  Job will not start running and failed saying that missing required parameter message

    Given I assign "tests/test-data/dmp-gs" to variable "testdata.path"
    And I assign "gs_secmaster_response_template.out" to variable "RESPONSE_TEMPLATENAME"

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
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
    # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    And I copy files below from local folder "${testdata.path}/gswf/EIS_Bloomberg" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_secmaster_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "BB_DOWNLOAD_DIR" to "${BB_DOWNLOAD_DIR}"
    And I set the workflow template parameter "BB_UPLOAD_DIR" to "${BB_UPLOAD_DIR}"
    And I set the workflow template parameter "SN" to "191305"
    And I set the workflow template parameter "USER_NUMBER" to "3650834"
    And I set the workflow template parameter "WORK_STATION" to "0"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    And I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"
    And I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${testdata.path}/REQUEST_REPLY/BLOOMBERG/BBPerSec_Missing_Mandatory_Param_ExpectedResult.txt" and reference CSV file "testout/evidence/gswf/resp/asyncResponse.xml" should be successful and exceptions to be written to "${testdata.path}/REQUEST_REPLY/BLOOMBERG/001_bbPerSecurity_exceptions_${recon.timestamp}.csv" file


  Scenario: Verify Execution of EIS_BBPerSecurity Workflow with only mandatory parameters
  Instance ID will be generated and job will keep on running in started status in WFRI table

    Given I assign "tests/test-data/dmp-gs" to variable "testdata.path"
    And I assign "gs_secmaster_response_template.out" to variable "RESPONSE_TEMPLATENAME"

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
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """
    And I copy files below from local folder "${testdata.path}/gswf/EIS_Bloomberg" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/gs_secmaster_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "FIRM_NAME" to "dl790188"
    And I set the workflow template parameter "REQUEST_TYPE" to "EIS_Secmaster"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    And I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "STARTED":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I poll for maximum 60 seconds and expect the result of the SQL query below equals to "3":
#      """
#      ${testdata.path}/REQUEST_REPLY/SQL/BBPerSec_VerifyWorkFlowStatus_STARTED.sql
#      """
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM
    (
        SELECT
            instance_id FROM
            (
                SELECT instance_id FROM
                    (
                        SELECT
                            wfri.instance_id,
                            tokn1.instance_id prnt_instance_id
                        FROM
                            ft_wf_wfri wfri
                            LEFT JOIN ft_wf_tokn tokn1 ON ( wfri.prnt_token_id = tokn1.token_id )
                            JOIN ft_wf_wfdf wfdf USING ( workflow_id )
                    ) iview
                CONNECT BY PRIOR instance_id = prnt_instance_id
                START WITH prnt_instance_id = '${flowResultId}'
                UNION
                SELECT instance_id FROM ft_wf_wfri wfri
                WHERE wfri.instance_id = '${flowResultId}'
            )
    ) instance_id,ft_wf_wfri wfri,ft_wf_wfdf wfdf
    WHERE instance_id.instance_id = wfri.instance_id
    AND wfri.workflow_id = wfdf.workflow_id
    AND wfdf.workflow_nme IN (
        'Request Reply',
        'Split Requests',
        'EIS_BBPerSecurity'
    )
    AND   wfri.wf_runtime_stat_typ = 'STARTED'
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
