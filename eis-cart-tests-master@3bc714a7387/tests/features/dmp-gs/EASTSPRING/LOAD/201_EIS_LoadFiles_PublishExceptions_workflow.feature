#Feature History
#TOM-3768: Moved the feature file from as per new folder structure. Updated Feature Description

@dmp_smoke @load_files_publish_excep_wf @tom_3768
Feature: GC Smoke | Orchestrator | ESI | Load | Load Files and Publish Exception

  Scenario: TC_WF_1 - Test the workflow "EIS_LoadFiles_PublishExceptions" and Check if email is Triggered with Load Summary, Exception Details and File Attachment

    Given I assign "ESIINTRADAY_TRN_1_20171005_000003_test.out" to variable "INPUT_FILENAME"

    Then I copy files below from local folder "tests/test-data/dmp-gs/gswf/EIS_LoadFiles_PublishExceptions" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BNP_FIXEDHEADER"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"

    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST EIS LoadFiles Publish Exceptions - TC_WF_1"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "12"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 40 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "Parent Job created by EIS_LoadFiles_PublishExceptions":
      """
      SELECT JOB_CONFIG_TXT FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

    #assiging query to workflow template param is not recommended, since generic variable assignement def is not supporting multiline value, we are using like below.
    And I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT TASK_TOT_CNT,TASK_CMPLTD_CNT,TASK_SUCCESS_CNT,TASK_FAILED_CNT,TASK_PARTIAL_CNT,PRNT_JOB_ID from FT_T_JBLG
      WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}'
      AND PRNT_JOB_ID = (SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID = '${flowResultId}')
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "TASK_TOT_CNT;TASK_CMPLTD_CNT;TASK_SUCCESS_CNT;TASK_FAILED_CNT;TASK_PARTIAL_CNT;PRNT_JOB_ID" into same variables

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_V_SUM1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND FILENAME = '${INPUT_FILENAME}'
      AND TASK_TOT_CNT = ${TASK_TOT_CNT}
      AND TASK_CMPLTD_CNT = ${TASK_CMPLTD_CNT}
      AND TASK_SUCCESS_CNT = ${TASK_SUCCESS_CNT}
      AND TASK_FAILED_CNT = ${TASK_FAILED_CNT}
      AND TASK_PARTIAL_CNT = ${TASK_PARTIAL_CNT}
      """

    And I expect records should be present in table as per below query:
      """
      SELECT COUNT(*) AS RESULT FROM FT_V_DTL1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND ROUND(LST_NOTFCN_TMS,'MI') = ROUND((SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}'),'MI')
      AND FILENAME = '${INPUT_FILENAME}'
      """

    And I expect records should be present in table as per below query:
      """
      SELECT COUNT(*) AS RESULT FROM FT_T_NTEL
      WHERE LST_NOTFCN_TMS >= (SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}')
      """

         #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    Then I expect below files to be deleted to the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}" after processing:
      | ${INPUT_FILENAME} |

  Scenario: TC_WF_2 - Test the workflow "EIS_LoadFiles_PublishExceptions" and Check if email is Triggered with Load Summary and File Attachment, no Exception Details

    Given I assign "ESIINTRADAY_TRN_1_20171005_000003_test.out" to variable "INPUT_FILENAME"

    Then I copy files below from local folder "tests/test-data/dmp-gs/gswf/EIS_LoadFiles_PublishExceptions" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BNP_FIXEDHEADER"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

      #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"

    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST EIS LoadFiles Publish Exceptions - TC_WF_2"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "0"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"


    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 40 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "Parent Job created by EIS_LoadFiles_PublishExceptions":
      """
      SELECT JOB_CONFIG_TXT FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #assiging query to workflow template param is not recommended, since generic variable assignement def is not supporting multiline value, we are using like below.
    And I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT TASK_TOT_CNT,TASK_CMPLTD_CNT,TASK_SUCCESS_CNT,TASK_FAILED_CNT,TASK_PARTIAL_CNT,PRNT_JOB_ID from FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}'
      AND PRNT_JOB_ID = (SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID = '${flowResultId}')
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "TASK_TOT_CNT;TASK_CMPLTD_CNT;TASK_SUCCESS_CNT;TASK_FAILED_CNT;TASK_PARTIAL_CNT;PRNT_JOB_ID" into same variables

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_V_SUM1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND FILENAME = '${INPUT_FILENAME}'
      AND TASK_TOT_CNT = ${TASK_TOT_CNT}
      AND TASK_CMPLTD_CNT = ${TASK_CMPLTD_CNT}
      AND TASK_SUCCESS_CNT = ${TASK_SUCCESS_CNT}
      AND TASK_FAILED_CNT = ${TASK_FAILED_CNT}
      AND TASK_PARTIAL_CNT = ${TASK_PARTIAL_CNT}
      """

    And I expect records should be present in table as per below query:
      """
      SELECT COUNT(*) AS RESULT FROM FT_V_DTL1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND ROUND(LST_NOTFCN_TMS,'MI') = ROUND((SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}'),'MI')
      AND FILENAME = '${INPUT_FILENAME}'
      """

    And I expect records should be present in table as per below query:
      """
      SELECT COUNT(*) AS RESULT FROM FT_T_NTEL
      WHERE LST_NOTFCN_TMS >= (SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}')
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    Then I expect below files to be deleted to the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}" after processing:
      | ${INPUT_FILENAME} |

  Scenario: TC_WF_3 - Test the workflow "EIS_LoadFiles_PublishExceptions" and Email should not triggered as no records in NTEL

    Given I assign "ESIINTRADAY_TRN_20171020_mu_2_test.out" to variable "INPUT_FILENAME"

    Then I copy files below from local folder "tests/test-data/dmp-gs/gswf/EIS_LoadFiles_PublishExceptions" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BNP_FIXEDHEADER"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

      #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST EIS LoadFiles Publish Exceptions - TC_WF_3"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "false"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"


    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 40 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "Parent Job created by EIS_LoadFiles_PublishExceptions":
      """
      SELECT JOB_CONFIG_TXT FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #assiging query to workflow template param is not recommended, since generic variable assignement def is not supporting multiline value, we are using like below.
    And I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT TASK_TOT_CNT,TASK_CMPLTD_CNT,TASK_SUCCESS_CNT,TASK_FAILED_CNT,TASK_PARTIAL_CNT,PRNT_JOB_ID from FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}'
      AND PRNT_JOB_ID = (SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID = '${flowResultId}')
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "TASK_TOT_CNT;TASK_CMPLTD_CNT;TASK_SUCCESS_CNT;TASK_FAILED_CNT;TASK_PARTIAL_CNT;PRNT_JOB_ID" into same variables

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_V_SUM1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND FILENAME = '${INPUT_FILENAME}'
      AND TASK_TOT_CNT = ${TASK_TOT_CNT}
      AND TASK_CMPLTD_CNT = ${TASK_CMPLTD_CNT}
      AND TASK_SUCCESS_CNT = ${TASK_SUCCESS_CNT}
      AND TASK_FAILED_CNT = ${TASK_FAILED_CNT}
      AND TASK_PARTIAL_CNT = ${TASK_PARTIAL_CNT}
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "0":
      """
      SELECT COUNT(*) AS RESULT FROM FT_V_DTL1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND ROUND(LST_NOTFCN_TMS,'MI') = ROUND((SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}'),'MI')
      AND FILENAME = '${INPUT_FILENAME}'
      """

      # No Records in NTEL table
    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "0":
      """
      SELECT COUNT(*) AS RESULT FROM FT_T_NTEL
      WHERE LST_NOTFCN_TMS > (SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}')
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    Then I expect below files to be deleted to the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}" after processing:
      | ${INPUT_FILENAME} |

  Scenario: TC_WF_4 - Test the workflow "EIS_LoadFiles_PublishExceptions" and Check Email should triggered even if no records in NTEL

    Given I assign "ESIINTRADAY_TRN_20171020_mu_2_test.out" to variable "INPUT_FILENAME"

    Then I copy files below from local folder "tests/test-data/dmp-gs/gswf/EIS_LoadFiles_PublishExceptions" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BNP_FIXEDHEADER"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

      #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"

    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST EIS LoadFiles Publish Exceptions - TC_WF_4"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 40 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "Parent Job created by EIS_LoadFiles_PublishExceptions":
      """
      SELECT JOB_CONFIG_TXT FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #assiging query to workflow template param is not recommended, since generic variable assignement def is not supporting multiline value, we are using like below.
    And I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT TASK_TOT_CNT,TASK_CMPLTD_CNT,TASK_SUCCESS_CNT,TASK_FAILED_CNT,TASK_PARTIAL_CNT,PRNT_JOB_ID from FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}'
      AND PRNT_JOB_ID = (SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID = '${flowResultId}')
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "TASK_TOT_CNT;TASK_CMPLTD_CNT;TASK_SUCCESS_CNT;TASK_FAILED_CNT;TASK_PARTIAL_CNT;PRNT_JOB_ID" into same variables

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_V_SUM1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND FILENAME = '${INPUT_FILENAME}'
      AND TASK_TOT_CNT = ${TASK_TOT_CNT}
      AND TASK_CMPLTD_CNT = ${TASK_CMPLTD_CNT}
      AND TASK_SUCCESS_CNT = ${TASK_SUCCESS_CNT}
      AND TASK_FAILED_CNT = ${TASK_FAILED_CNT}
      AND TASK_PARTIAL_CNT = ${TASK_PARTIAL_CNT}
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "0":
      """
      SELECT COUNT(*) AS RESULT FROM FT_V_DTL1
      WHERE PRNT_JOB_ID = '${PRNT_JOB_ID}'
      AND ROUND(LST_NOTFCN_TMS,'MI') = ROUND((SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}'),'MI')
      AND FILENAME = '${INPUT_FILENAME}'
      """

      # No Records in NTEL table
    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "0":
      """
      SELECT COUNT(*) AS RESULT FROM FT_T_NTEL
      WHERE LST_NOTFCN_TMS > (SELECT JOB_START_TMS from FT_T_JBLG where INSTANCE_ID = '${flowResultId}')
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    Then I expect below files to be deleted to the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}" after processing:
      | ${INPUT_FILENAME} |