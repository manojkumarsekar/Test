#https://jira.intranet.asia/browse/TOM-4971
#https://jira.intranet.asia/browse/TOM-5191
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 09/09/2019      TOM-4971    Development - BNP Performance Attribution L3 file Load
# 24/09/2019      TOM-5191    UAT issue fix - timestamp to be considered for startdate and enddate
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New

@dw_interface_performance
@dmp_dw_regression
@tom_4971 @tom_4971_mandatory @tom_5191 @perf_attrib_l3 @eisdev_5525
Feature: Test BNP performance L3 file for mandatory fields

  This is to test if BNP L3 performance file is throwing errors for mandatory fields - FundName, Breakdown fields missing

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/Perf_Attrib_L3/Inbound" to variable "testdata.path"

    And I execute below query
    """
     UPDATE ft_t_wpea SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
    """

    And I execute below query
      """
     ${testdata.path}/sql/AccountBMSetup.sql
      """

  Scenario: TC_2: Load BNP L3 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | 1003_PERF_Mandatory_L3.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | 1003_PERF_Mandatory_L3.csv    |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='0' and TASK_PARTIAL_CNT = '1'
      """

  Scenario: TC_3: Verify if the exception is thrown

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '60001'
      AND APPL_ID = 'TPS'
      AND PART_ID = 'TRANS'
      AND MSG_SEVERITY_CDE = 40
      AND MAIN_ENTITY_ID = '31072018:31072019:ALAIEFTST::1:US3168271043:CashandEquivalents:CashandEquivalents:SubTotal:::'
      AND MAIN_ENTITY_ID_CTXT_TYP = 'IRP:ISIN:BRK:DP:LVL'
      AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, Fund Name, Breakdown is not present in the input record.'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """