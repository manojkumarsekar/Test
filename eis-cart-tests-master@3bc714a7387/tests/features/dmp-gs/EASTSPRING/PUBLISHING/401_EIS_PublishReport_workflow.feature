#Feature History
#TOM-4884 : New Workflow Created
#https://collaborate.intranet.asia/display/TOMR4/EIS_PublishReport
# New test scenario added for email generation when there are no results

@dmp_smoke @EIS_PublishReport @tom_4884 @eisdev_6314
Feature: GC Smoke | Orchestrator | ESI | Publishing | EIS_PublishReport
  This workflow publishes report based on the SQL query provided as part of the input parameter.

  Scenario: Verify Report is Published without attachment
  Email should be generated without attachment

    Given I set the workflow template parameter "ATTACHMENT_FILENAME" to "Data_Report.xlsx"
    And I set the workflow template parameter "ATTACHMENT_REQUIRED" to "false"
    And I set the workflow template parameter "DATA_HEADER" to "RDM Security Type, Count"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "DATA_SQL" to "select cl_value , count(*) from ft_t_iscl where indus_cl_set_id = 'RDMSCTYP' group by cl_value"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Publish Report without attachment"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: Verify Report is Published with Details Count > Row Count.
  Data should not be published in the email body

    Given I set the workflow template parameter "ATTACHMENT_FILENAME" to "Data_Report.xlsx"
    And I set the workflow template parameter "ATTACHMENT_REQUIRED" to "true"
    And I set the workflow template parameter "DATA_HEADER" to "RDM Security Type, Count"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "DATA_SQL" to "select cl_value , count(*) from ft_t_iscl where indus_cl_set_id = 'RDMSCTYP' group by cl_value"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Publish Report without Details in Email Body Test"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: Verify Report is Published with Details Count < Row Count.
  Data should be published in the email body

    Given I set the workflow template parameter "ATTACHMENT_FILENAME" to "Data_Report.xlsx"
    And I set the workflow template parameter "ATTACHMENT_REQUIRED" to "true"
    And I set the workflow template parameter "DATA_HEADER" to "RDM Security Type, Count"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "100"
    And I set the workflow template parameter "DATA_SQL" to "select cl_value , count(*) from ft_t_iscl where indus_cl_set_id = 'RDMSCTYP' group by cl_value"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Publish Report with Details in Email Body Test"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: Empty Resultset. Email is not generated

    Given I set the workflow template parameter "ATTACHMENT_FILENAME" to "Data_Report.xlsx"
    And I set the workflow template parameter "ATTACHMENT_REQUIRED" to "true"
    And I set the workflow template parameter "DATA_HEADER" to "RDM Security Type, Count"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "100"
    And I set the workflow template parameter "DATA_SQL" to "select cl_value , count(*) from ft_t_iscl where indus_cl_set_id = 'RDMSCTYP11' group by cl_value"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "No Email"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: Empty Result set. Email to be generated

    Given I set the workflow template parameter "ATTACHMENT_FILENAME" to "Data_Report.xlsx"
    And I set the workflow template parameter "ATTACHMENT_REQUIRED" to "true"
    And I set the workflow template parameter "DATA_HEADER" to "RDM Security Type, Count"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "100"
    And I set the workflow template parameter "DATA_SQL" to "select cl_value , count(*) from ft_t_iscl where indus_cl_set_id = 'RDMSCTYP11' group by cl_value"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "No Email"
    And I set the workflow template parameter "NO_DATA_EMAILSUB" to "No Result email"
    And I set the workflow template parameter "NO_DATA_EMAILBODY" to "Test email"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  @ignore
  Scenario: DATA_DETAILS_COUNT not provided

    Given I set the workflow template parameter "ATTACHMENT_FILENAME" to "Data_Report.xlsx"
    And I set the workflow template parameter "DATA_HEADER" to "RDM Security Type, Count"
    And I set the workflow template parameter "DATA_SQL" to "select cl_value , count(*) from ft_t_iscl where indus_cl_set_id = 'RDMSCTYP11' group by cl_value"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Publish Report without DATA_DETAILS_COUNT Test"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PublishReport/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """