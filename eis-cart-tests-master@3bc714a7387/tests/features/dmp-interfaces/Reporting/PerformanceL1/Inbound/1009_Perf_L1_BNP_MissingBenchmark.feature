#https://jira.intranet.asia/browse/TOM-4930
#https://collaborate.intranet.asia/display/TOM/Performance+Data+Mart+-New
# 14/07/2020      EISDEV-6591  As part of this JIRA, OOB Patch Starterset 128 has been updated which fixes the table name in NTEL exception
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 22/12/2020      EISDEV-5173 Change in input file date format

@dw_interface_performance
@dmp_dw_regression
@tom_4930 @tom_4930_missingbenchmark @perf_l1 @tom_5171 @eisdev_6591 @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file for missing Benchmark

  This is to test if BNP L1 performance file is throwing errors for missing Benchmark

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/PerformanceL1/Inbound" to variable "testdata.path"
    And I assign "The Account/Benchmark Role BL1PRIM for the Account Alternate Identifier  'IRPID - AGOCABTST' received from EIS could not be retrieved from the WACKGSWAccountAccountRole table" to variable "PERF_PUBLISHING_ERRORMSG"

    #WCRI is deleted for both portfolio and benchmark as cleanup before loading
    And I execute below query
      """
       UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')  WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
       UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')  WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'ALASPSTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
      """

    #Accout and Benchmark Creation
    And I execute below query
    """
     ${testdata.path}/sql/AccountBMSetup.sql
    """

    #Benchmark update
    And I execute below query
    """
     ${testdata.path}/sql/UpdateBM.sql
    """

  Scenario: TC_2: Load BNP L1 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_L1_GrossAllFeesOrWthdgTaxes.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | PERF_L1_GrossAllFeesOrWthdgTaxes.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1               |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_FAILED_CNT ='1'
      """

  Scenario: TC_3: Verify if the exception is thrown

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '60008'
      AND APPL_ID = 'CONCTNS'
      AND PART_ID = 'NESTED'
      AND MSG_SEVERITY_CDE = 40
      AND MAIN_ENTITY_ID = 'AGOCABTST:Gross of all fees / wthdg taxes:TWRR'
      AND MAIN_ENTITY_ID_CTXT_TYP = 'IRPID:RTYP:RSRC'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

    And I expect value of column "PERF_LOAD_ERROR" in the below SQL query equals to "${PERF_PUBLISHING_ERRORMSG}":
     """
      SELECT CHAR_VAL_TXT AS PERF_LOAD_ERROR FROM FT_T_NTEL
      WHERE LAST_CHG_TRN_ID IN
        (SELECT TRN_ID FROM FT_T_TRID
        WHERE JOB_ID ='${JOB_ID}')
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_CNT = '1'
    """
