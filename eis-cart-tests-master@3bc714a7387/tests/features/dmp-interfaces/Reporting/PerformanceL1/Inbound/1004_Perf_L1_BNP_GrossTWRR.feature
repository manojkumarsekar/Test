#https://jira.intranet.asia/browse/TOM-4930
# https://jira.intranet.asia/browse/TOM-5143
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 09/09/2019      TOM-4930    Development - BNP Performance L1 file Load
# 20/09/2019      TOM-5143    Changes for remodeling in inbound and outbound both - Benchmark returns are stored against its respective portfolio
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 22/12/2020      EISDEV-5173 Change in input file date format
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Performance+Data+Mart+-New

@dw_interface_performance
@dmp_dw_regression
@tom_4930 @tom_4930_GrossTWRR @tom_5143 @perf_l1 @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file for return type Gross TWRR

  This is to test if BNP L1 performance file is getting loaded in DWH for return type Gross of all fees and its net columns are stored correctly

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/PerformanceL1/Inbound" to variable "testdata.path"

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

  Scenario: TC_2: Load BNP L1 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_L1_GrossTWRR.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | PERF_L1_GrossTWRR.csv  |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
      """

  Scenario: TC_3: Perform checks in WCRI for multiple scenarios for account returns

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
      """

    Then I expect value of column "WCRI_GrossTWRR_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS WCRI_GrossTWRR_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1)
      and return_typ = 'GrossTWRR' and DW_STATUS_NUM =1
      """

    Then I expect value of column "WCRI_NetTWRRGrossTWRR_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS WCRI_NetTWRRGrossTWRR_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1)
      and return_typ = 'NetTWRRGrossTWRR' and DW_STATUS_NUM =1
      """

    Then I expect value of column "WCRI_NetSalesChargeTWRRGrossTWRR_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS WCRI_NetSalesChargeTWRRGrossTWRR_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1)
      and return_typ = 'NetSalesChargeTWRRGrossTWRR' and DW_STATUS_NUM =1
      """
