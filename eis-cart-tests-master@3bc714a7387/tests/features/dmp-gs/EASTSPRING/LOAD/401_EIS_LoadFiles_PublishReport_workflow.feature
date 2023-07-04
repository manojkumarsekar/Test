#Feature History
#TOM-4894 : New Feature file Created
#https://collaborate.intranet.asia/display/TOMR4/EIS_PublishReport
@dmp_smoke @401_load_and_publish_report @tom_4894  @dmp_gs_upgrade
Feature: GC Smoke | Orchestrator | ESI | Load | Load and Publish Report
  This workflow has been created to load input file and publish report based on the SQL query provided as part of the input parameter.

  Scenario: Generate input data from template

    Given I assign "esi_security_analytics_models_eod_weight_price.xml" to variable "INPUT_FILENAME"
    And I assign "esi_security_analytics_models_eod_weight_price_template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "tests/test-data/dmp-interfaces/Benchmarks/DriftedBenchmark" to variable "testdata.path"

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/infiles"

  Scenario: Load and Publish Report

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_RISK_ANALYTICS"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "50"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Load and Publish Report Smoke Test"
    And I set the workflow template parameter "DATA_HEADER" to "CLOSE_CPRC, CRRNT_FACE_CAMT,BNCHMRK_VAL_CURR_CDE"
    And I set the workflow template parameter "DATA_SQL" to "select CLOSE_CPRC, CRRNT_FACE_CAMT,BNCHMRK_VAL_CURR_CDE from ft_t_bnvl where Bnchmrk_Val_Tms = to_date('07/04/2019','MM/DD/YYYY')"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "Mahesh.Gummaraju@eastspring.com"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/response1.xml"
    Then I extract value from the XML file "testout/evidence/gswf/resp/response1.xml" with xpath "//*[local-name() = 'flowResultId']" to variable "flowResultId"

    Then I poll for maximum 90 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE INSTANCE_ID='${flowResultId}'
    """

    And I expect value of column "JBLG_CHILD_ROW_COUNT" in the below SQL query equals to "2":
    """
    SELECT count(*) as JBLG_CHILD_ROW_COUNT FROM FT_T_JBLG
    WHERE PRNT_JOB_ID IN (SELECT JOB_ID FROM FT_T_JBLG
    WHERE INSTANCE_ID='${flowResultId}')
    """