#https://jira.intranet.asia/browse/TOM-4160
#TOM-4160 : Expire Research Report once it reaches the expiry date.

@tom_4160 @dmp_twrr_functional @dmp_tw_functional @dmp_gs_upgrade
Feature: Expire Research Report

  Scenario: TC_1: Prepare Research Report Data

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I execute below query
    """
    ${testdata.path}/sql/CreateResearchReportData.sql
    """

  Scenario: TC_2: Call Expire Research Report Workflow

    Given I set the workflow template parameter "SQL_PROC_NAME" to "eitw_ResearchNote_pkg.expire"
    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/flowResultIdQuery.xpath" to variable "flowResultId"
    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":

    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: TC_3: Data Verifications

  # Validation 1: Total Expired Research Report Should be 1
    Then I expect value of column "EXPIRED_ROW_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(1) AS EXPIRED_ROW_COUNT FROM FT_T_RSR1 WHERE EXT_RSRSH_ID='Test-Report-4160-A' AND EXT_STATUS='TWRES_EXPIRED' AND END_TMS IS NOT NULL
        """

  # Validation 2: Total Non Expired Research Report Should be 2
    Then I expect value of column "NON_EXPIRED_ROW_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(1) AS NON_EXPIRED_ROW_COUNT FROM FT_T_RSR1 WHERE EXT_RSRSH_ID IN('Test-Report-4160-B', 'Test-Report-4160-C') AND EXT_STATUS='ACTIVE' AND END_TMS IS NULL
        """
