#Feature History
#TOM-3768: Updated Feature and Scenario Description. Updated the SQL Query to include BNCH and ISPC tables
#https://jira.pruconnect.net/browse/EISDEV-5245 : Audit Workflow - ESI_CompareJSON - Has Error after adding ISSU parameter to the workflow

@dmp_smoke @comparejson_wf @tom_3768 @pvt @dmp_gs_upgrade @tom_5245
Feature: GC Smoke | Orchestrator | ESI | Audit | Compare JSON

  Scenario: Verify Execution of Compare JSON Workflow with all parameters

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      WITH jblg AS (SELECT max(job_Start_tms) tms FROM fT_T_jblg WHERE job_config_txt = 'Audit Generation Job' AND job_stat_typ = 'CLOSED')
      select * from (SELECT DISTINCT e.cross_ref_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000') , 'O' FROM ft_ev_evot e, jblg j
      WHERE e.TBL_ID IN ('ACCT','BNCH','ISPC','ISSU')  and (e.last_chg_tms > j.tms)) t
      """
    And I set the workflow template parameter "NO_OF_THREADS" to "10"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "PASS":
      """
      SELECT NVL(
        (
            SELECT CASE WHEN job_stat_typ = 'CLOSED' THEN 'PASS' ELSE 'FAIL' END
            FROM ft_t_jblg
            WHERE instance_id = '${flowResultId}'
        ), 'PASS') AS result
      FROM dual
      """

    #Event Result Verifications

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

  Scenario: Verify Execution of Compare JSON Workflow with NULL parameters

    Given I set the workflow template parameter "SQL_QUERY" to ""
    And I set the workflow template parameter "NO_OF_THREADS" to "10"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "STARTED":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    And I pause for 5 seconds

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "true"


    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_WF_TOKN
    WHERE INSTANCE_ID = '${flowResultId}'
    AND TOKEN_STAT_TYP = 'FAILED'
    """

    Given I execute below query
    """
    UPDATE FT_T_JBLG
    SET job_stat_typ = 'CLOSED'
    WHERE INSTANCE_ID = '${flowResultId}';
    COMMIT
    """

    Given I execute below query
    """
    UPDATE FT_WF_WFRI
    SET WF_RUNTIME_STAT_TYP = 'FAILED'
    WHERE INSTANCE_ID = '${flowResultId}';
    COMMIT
    """