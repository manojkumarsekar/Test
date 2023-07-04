#Feature History
#TOM-3768: Created New Feature file to Sanity test "Refresh SOI" workflow

@dmp_smoke @refreshsoi_wf @tom_3768
Feature: GC Smoke | Orchestrator | ESI | Pricing | Refresh SOI

  Scenario: Verify Execution of Refresh SOI Workflow with all parameters

   #Refresh SOI
    Given I set the workflow template parameter "GROUP_NAME" to "ESIMANOVRD"
    And I set the workflow template parameter "NO_OF_BRANCH" to "5"
    And I set the workflow template parameter "QUERY_NAME" to "EIS_REFRESH_MANUAL_PRICE_SOI"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 600 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I pause for 30 seconds

  #Verify Data:
    Then I expect value of column "PRICE_COUNT_POST_REFRESH" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS PRICE_COUNT_POST_REFRESH
    FROM FT_V_PRC1
    WHERE TRUNC(PRC1_ADJST_TMS) = TRUNC(SYSDATE) AND PRC1_GRP_NME ='ESIMANOVRD'
    """