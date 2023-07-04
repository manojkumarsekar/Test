#Feature History
#@dmp_smoke and @performance_attribution_wf tags are removed from this test as this workflow is not production and not valid to test at the moment
#TOM-3768: Moved the feature file from as per new folder structure.

Feature: GC Smoke | Orchestrator | EIS | Publishing | Performance Attribution Publishing

  Scenario: Verify Execution of Workflow for EQUITY with DATE Level

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT * FROM (SELECT DISTINCT EXT_PA_PORTFOLIO_CODE , TO_CHAR(EXT_PA_PERIOD_END_DATE , 'DD-MM-YYYY') AS EXT_PA_PERIOD_END_DATE, 'D' , 'EQP1' , EXT_PA_ATTRIB_MODEL_CODE, 'Y',  'MAX' FROM FT_T_EQP1)
      WHERE ROWNUM = 1
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "EXT_PA_PORTFOLIO_CODE;EXT_PA_PERIOD_END_DATE;EXT_PA_ATTRIB_MODEL_CODE" into same variables

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/flowResultIdQuery.xpath" to variable "flowResultId"

      #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/bnp/performance/Equity" after processing:
      | ${EXT_PA_PERIOD_END_DATE}__${EXT_PA_PORTFOLIO_CODE}__${EXT_PA_ATTRIB_MODEL_CODE}_SEC.csv |

  Scenario: Verify Execution of Workflow for EQUITY expecting system should throw ERROR

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT * FROM (SELECT DISTINCT EXT_PA_PORTFOLIO_CODE , TO_CHAR(EXT_PA_PERIOD_END_DATE , 'DD-MM-YYYY') AS EXT_PA_PERIOD_END_DATE, 'D' , 'EQP1' , EXT_PA_ATTRIB_MODEL_CODE, 'Y',  'MAX' FROM FT_T_EQP1)
      WHERE ROWNUM = 1
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "EXT_PA_PORTFOLIO_CODE;EXT_PA_PERIOD_END_DATE;EXT_PA_ATTRIB_MODEL_CODE" into same variables

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/flowResultIdQuery.xpath" to variable "flowResultId"

      #waiting intentionally
    Then I pause for 10 seconds

      #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "STARTED":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "OPEN":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/bnp/performance/Equity" after processing:
      | ${EXT_PA_PERIOD_END_DATE}__${EXT_PA_PORTFOLIO_CODE}__${EXT_PA_ATTRIB_MODEL_CODE}_SEC.csv |

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "ERROR":
      """
      select CFG.PUB_STATUS from FT_CFG_PUB1 CFG
      join ft_t_jblg JBLG
      On round(CFG.start_tms,'MI') = round(JBLG.JOB_START_TMS,'MI')
      and trunc(CFG.start_tms) = trunc(sysdate)
      And JBLG.instance_id='${flowResultId}'
      And CFG.PUB_DESCRIPTION = 'Old published files still present in the publishing folder'
      """

      #This is to clear the generated file
    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/performance/Equity" if exists:
      | ${EXT_PA_PERIOD_END_DATE}__${EXT_PA_PORTFOLIO_CODE}__${EXT_PA_ATTRIB_MODEL_CODE}_SEC.csv |

  Scenario: Verify Execution of Workflow for FIXED INCOME with MONTH Level

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      SELECT * FROM (select distinct EXT_PA_PORTFOLIO_CODE , TO_CHAR(EXT_PA_HOLDING_DATE , 'MM-YYYY') EXT_PA_HOLDING_DATE, 'M' , 'FIP1' ,'NA' model,'NA' sec,'NA' timestamp from FT_T_FIP1)
      WHERE ROWNUM = 1
      """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "EXT_PA_PORTFOLIO_CODE;EXT_PA_HOLDING_DATE" into same variables

      #This statement is specific to requirement, when user chosen MONTH level file generation, File is getting generated with Max day of Month.
      #Ex: $EXT_PA_HOLDING_DATE is '04-2017' (April month), but the file is getting generated as '30-04-2017'
    And I execute query "SELECT TO_CHAR(LAST_DAY(TO_DATE('01-${EXT_PA_HOLDING_DATE}','DD-MM-YYYY')),'DD-MM-YYYY') EXT_PA_HOLDING_DATE from dual" and extract values of "EXT_PA_HOLDING_DATE" into same variables

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/flowResultIdQuery.xpath" to variable "flowResultId"

      #waiting intentionally
    Then I pause for 10 seconds

      #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/bnp/performance/FixedIncome" after processing:
      | ${EXT_PA_PORTFOLIO_CODE}__${EXT_PA_HOLDING_DATE}.csv |

  Scenario: Verify Execution of Workflow for FIXED INCOME with MONTH Level expecting system should throw ERROR

    Given I set the workflow template parameter "SQL_QUERY" to
        """
        SELECT * FROM (select distinct EXT_PA_PORTFOLIO_CODE , TO_CHAR(EXT_PA_HOLDING_DATE , 'MM-YYYY') EXT_PA_HOLDING_DATE, 'M' , 'FIP1' ,'NA' model,'NA' sec,'NA' timestamp from FT_T_FIP1)
        WHERE ROWNUM = 1
        """

    And I execute query "${gs.wf.template.param.SQL_QUERY}" and extract values of "EXT_PA_PORTFOLIO_CODE;EXT_PA_HOLDING_DATE" into same variables

      #This statement is specific to requirement, when user chosen MONTH level file generation, File is getting generated with Max day of Month.
      #Ex: $EXT_PA_HOLDING_DATE is '04-2017' (April month), but the file is getting generated as '30-04-2017'

    And I execute query "SELECT TO_CHAR(LAST_DAY(TO_DATE('01-${EXT_PA_HOLDING_DATE}','DD-MM-YYYY')),'DD-MM-YYYY') EXT_PA_HOLDING_DATE from dual" and extract values of "EXT_PA_HOLDING_DATE" into same variables

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_PerformanceAttrib_Publishing/flowResultIdQuery.xpath" to variable "flowResultId"

      #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "STARTED":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "OPEN":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

      #Event Result Verifications
    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "false"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/bnp/performance/FixedIncome" after processing:
      | ${EXT_PA_PORTFOLIO_CODE}__${EXT_PA_HOLDING_DATE}.csv |

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "ERROR":
      """
      select CFG.PUB_STATUS from FT_CFG_PUB1 CFG
      join ft_t_jblg JBLG
      On round(CFG.start_tms,'MI') = round(JBLG.JOB_START_TMS,'MI')
      and trunc(CFG.start_tms) = trunc(sysdate)
      And JBLG.instance_id='${flowResultId}'
      And CFG.PUB_DESCRIPTION = 'Old published files still present in the publishing folder'
      """

      #This is to clear the generated file
    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/performance/FixedIncome" if exists:
      | ${EXT_PA_PORTFOLIO_CODE}__${EXT_PA_HOLDING_DATE}.csv |
