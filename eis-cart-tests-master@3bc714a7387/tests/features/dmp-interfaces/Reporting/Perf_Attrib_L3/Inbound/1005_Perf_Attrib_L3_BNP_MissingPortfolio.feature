#https://jira.intranet.asia/browse/TOM-4971
# https://jira.intranet.asia/browse/TOM-5191
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 13/09/2019      TOM-4971    Development - BNP Performance Attribution L3 file Load
# 24/09/2019      TOM-5191    UAT issue fix - timestamp to be considered for startdate and enddate
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# 14/07/2020      EISDEV-6591  As part of this JIRA, OOB Patch Starterset 128 has been updated which fixes the table name in NTEL exception
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New

@dw_interface_performance
@dmp_dw_regression
@tom_4971 @tom_4971_missingacct @tom_5191 @perf_attrib_l3 @eisdev_5525 @eisdev_6591
Feature: Test BNP performance L3 file for missing portfolio

  This is to test if BNP L3 performance file is throwing errors for missing portfolio

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

    #Accout Deletion
    And I execute below query
    """
     ${testdata.path}/sql/UpdateAccount.sql
    """

  Scenario: TC_2: Load BNP L3 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | 1001_PERF_INSERT_L3.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | 1001_PERF_INSERT_L3.csv       |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_FAILED_CNT ='1'
      """

  Scenario: TC_3: Verify if the exception is thrown

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | IRPID ALAIEFTST EIS GSWWACKAccount                                                                  |
      | NOTFCN_ID               | 26                                                                                                  |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                |
      | MAIN_ENTITY_ID_CTXT_TYP | IRP:ISIN:BRK:DP:LVL                                                                                 |
      | MAIN_ENTITY_ID          | 31072018:31072019:ALAIEFTST:COUNTRY POCKET:1:US3168271043:CashandEquivalents:CashandEquivalents:Sub |
      | MSG_SEVERITY_CDE        | 40                                                                                                  |
      | APPL_ID                 | CONCTNS                                                                                             |
      | PART_ID                 | NESTED                                                                                              |