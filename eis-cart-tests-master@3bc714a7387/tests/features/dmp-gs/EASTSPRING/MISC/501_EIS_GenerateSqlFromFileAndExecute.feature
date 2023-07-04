#Feature History
#TOM-4884: Initial Version for new Workflow
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR4&title=EIS_GenerateSqlFromFileAndExecute

@dmp_smoke @EIS_GenerateSqlFromFileAndExecute @tom_4883
Feature: GC Smoke | Orchestrator | ESI | Misc | EIS_GenerateSqlFromFileAndExecute
  This workflow generates sql statements based on the translation written in the MDX for a given input file and executes the statements to Database.

  Scenario: Verify Workflow is Executed for Multiple Messages

    Given I assign "esi_security_analytics_models_20190102.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-gs/gswf/EIS_GenerateSqlFromFileAndExecute" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BRS_RISK_ANALYTICS"
    And I set the workflow template parameter "FileURI" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "TRANSLATIONMDX" to "db://resource/mapping/EASTSPRING/TRANSLATION/FILETOSQL/EIS_BRS_DMP_RISK_ANALYTICS_DELETE.mdx"

    Then I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_GenerateSqlFromFileAndExecute/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_GenerateSqlFromFileAndExecute/flowResultIdQuery.xpath" to variable "flowResultId"

    And I pause for 5 seconds

    And I execute below query and extract values of "JOB_ID" into same variables
     """
     SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
     """

    Then I poll for maximum 90 seconds and expect the result of the SQL query below equals to "DONE":
     """
     SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
     """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
     """
     SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
     """

  #Verify Data
    Then I expect value of column "bnvl_count" in the below SQL query equals to "0":
     """
     select count(*) as bnvl_count from ft_t_bnvl where bnch_oid in
     (select bnch_oid from ft_t_bnid where BNCHMRK_ID in (select distinct Substr(MAIN_ENTITY_ID,11)
     from ft_t_trid where job_id = '${JOB_ID}' and main_entity_id is not null))
     and BNCHMRK_VAL_TMS = to_date('1/2/2019','MM/DD/YYYY')
    """