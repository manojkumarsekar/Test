#https://jira.intranet.asia/browse/TOM-4675

@gc_interface_research_report
@dmp_regression_unittest
@dmp_taiwan
@tom_4675
Feature: Research Report - Report Validation is end dating previous report and vice versa
  This feature will test the validation of research report

  This feature is to test scenario where
  1. Load research report xml to set up RSR1
  2. Run Research Report wrapper to check whether it invalidate only one report basis on validation criteria

  Scenario: TC1: Assignment of variables and Clearing the research report

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "researchreport_inputfile_4675.xml" to variable "RESEARCH_REPORT_FILE"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/request.xmlt" to variable "RESEARCHREPORT_WORKFLOW"

    And I execute below query
    """
    ${testdata.path}/sql/ClearScript_TOM_4675.sql
    """

  Scenario: TC2: Loading Research report xml in DMP

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RESEARCH_REPORT_FILE} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${RESEARCH_REPORT_FILE} |
      | MESSAGE_TYPE  | EITW_MT_RESEARCH_REPORT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    Then I expect value of column "RSR1_COUNT" in the below SQL query equals to "2":
    """
     SELECT COUNT(*) AS RSR1_COUNT FROM FT_T_RSR1 WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM01JN51' AND END_TMS IS NULL)
     AND (EXT_RSRSH_ID LIKE '%29410%' OR EXT_RSRSH_ID LIKE '%29411%')
    """

    #update the parent job id
    Then I execute below query
    """
     UPDATE FT_T_JBLG SET PRNT_JOB_ID = '00TEST4675eXu001' WHERE JOB_ID = '${JOB_ID}';
     COMMIT
    """

  Scenario: TC3: Running Research Report wrapper to test whether correct RSRI getting invalidate.

    Given I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |


    Then I expect value of column "RSR1_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS RSR1_COUNT FROM FT_T_RSR1 WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM01JN51' AND END_TMS IS NULL)
     AND (EXT_RSRSH_ID LIKE '%29410%' OR EXT_RSRSH_ID LIKE '%29411%')
     AND END_TMS IS NULL
    """