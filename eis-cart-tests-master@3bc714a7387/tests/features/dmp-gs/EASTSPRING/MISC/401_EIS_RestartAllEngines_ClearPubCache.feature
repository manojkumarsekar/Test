#Feature History
#TOM-3805: Smoke test for workflow

@dmp_smoke @restart_engine_wf @tom_3805
Feature: GC Smoke | Orchestrator | ESI | Misc | EIS_RestartAllEngines_ClearPubCache

  Scenario: Validate Smoke test for Custom Workflow EIS_RestartAllEngines_ClearPubCache

  # Re-start Engine

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_RestartAllEngines_ClearPubCache/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_RestartAllEngines_ClearPubCache/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """