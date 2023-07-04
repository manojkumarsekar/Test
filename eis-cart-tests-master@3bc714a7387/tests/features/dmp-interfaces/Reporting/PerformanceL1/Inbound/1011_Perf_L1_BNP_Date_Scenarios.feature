#https://jira.intranet.asia/browse/TOM-5192
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
#24/09/2019      TOM-5192    UAT issues fixes - inbound mapping changes for date format issue
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 22/12/2020      EISDEV-5173 Change in input file date format
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Performance+Data+Mart+-New

@dw_interface_performance
@dmp_dw_regression
@tom_5192 @tom_5192_L1 @perf_l1 @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file for verification of dates stored in database

  This is to test if BNP L1 performance file is getting loaded and test below scenarios
  1. Date with below different scenarios are stored correctly or not:-
  i)    Date with current year 2019
  ii)   Date with year 1999
  iii)  Date with year 2000
  iv)   Date with year more than 2019 (current year) but less than 2029 (less than current year plus 10 years) :- 2020
  v)    Date with year 2021
  vi)   Date with year 2001
  vii)   Date with year 2022

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/PerformanceL1/Inbound" to variable "testdata.path"

    #WCRI is deleted for both portfolio and benchmark as cleanup before loading
    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'ALASPSTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
    """

    #In order to make feature file re-runnable, existing fund performance & related data is cleaned up
    And I execute below query
    """
     ${testdata.path}/sql/AccountBMSetup.sql
    """

  Scenario: Load BNP L1 performance file having 1 records

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_L1_Date_Verification.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_L1_Date_Verification.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='7'
    """

  Scenario: Perform checks in WCRI for multiple scenarios

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "20":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and  DW_STATUS_NUM =1
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications of dates in base and derived return types for all dates
      | Column            | Query                                                                                                                                                                                                                                                                                                                         |
      | LPM1_Value_Date_1 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='01/05/2019'  |
      | LPM1_Value_Date_2 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='02/05/1999'              |
      | LPM1_Value_Date_3 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='03/05/2000'              |
      | LPM1_Value_Date_4 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='04/05/2020'                 |
      | LPM1_Value_Date_5 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='05/05/2021'                    |
      | LPM1_Value_Date_6 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='06/05/2001'                   |
      | LPM1_Value_Date_7 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='01/07/2022'  |
      | LPM1_3M_Date_1    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='07/05/2019' |
      | LPM1_3M_Date_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='08/05/1999'             |
      | LPM1_3M_Date_3    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='09/05/2000'             |
      | LPM1_3M_Date_4    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='10/05/2020'                |
      | LPM1_3M_Date_5    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='11/05/2021'                   |
      | LPM1_3M_Date_6    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='12/05/2001'                  |
      | LPM1_3M_Date_7    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='07/07/2022' |
      | LPM1_6MDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='13/05/2019'  |
      | LPM1_6MDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='14/05/1999'              |
      | LPM1_6MDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='15/05/2000'              |
      | LPM1_6MDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='16/05/2020'                 |
      | LPM1_6MDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='17/05/2021'                    |
      | LPM1_6MDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='18/05/2001'                   |
      | LPM1_6MDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='13/07/2022'  |
      | LPM1_YTDDate_1    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='19/05/2019' |
      | LPM1_YTDDate_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='20/05/1999'             |
      | LPM1_YTDDate_3    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='21/05/2000'             |
      | LPM1_YTDDate_4    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='22/05/2020'                |
      | LPM1_YTDDate_5    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='23/05/2021'                   |
      | LPM1_YTDDate_6    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='24/05/2001'                  |
      | LPM1_YTDDate_7    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='19/07/2022' |
      | LPM1_1YDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='25/05/2019'  |
      | LPM1_1YDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='26/05/1999'              |
      | LPM1_1YDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='27/05/2000'              |
      | LPM1_1YDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='28/05/2020'                 |
      | LPM1_1YDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='29/05/2021'                    |
      | LPM1_1YDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='30/05/2001'                   |
      | LPM1_1YDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='25/07/2022'  |
      | LPM1_2YDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='01/06/2019'  |
      | LPM1_2YDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='02/06/1999'              |
      | LPM1_2YDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='03/06/2000'              |
      | LPM1_2YDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='04/06/2020'                 |
      | LPM1_2YDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='05/06/2021'                    |
      | LPM1_2YDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='06/06/2001'                   |
      | LPM1_2YDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='01/08/2022'  |
      | LPM1_3YDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='07/06/2019'  |
      | LPM1_3YDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='08/06/1999'              |
      | LPM1_3YDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='09/06/2000'              |
      | LPM1_3YDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='10/06/2020'                 |
      | LPM1_3YDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='11/06/2021'                    |
      | LPM1_3YDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='12/06/2001'                   |
      | LPM1_3YDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='07/08/2022'  |
      | LPM1_5YDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='13/06/2019'  |
      | LPM1_5YDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='14/06/1999'              |
      | LPM1_5YDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='15/06/2000'              |
      | LPM1_5YDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='16/06/2020'                 |
      | LPM1_5YDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='17/06/2021'                    |
      | LPM1_5YDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='18/06/2001'                   |
      | LPM1_5YDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='13/08/2022'  |
      | LPM1_7YDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='19/06/2019'  |
      | LPM1_7YDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='20/06/1999'              |
      | LPM1_7YDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='21/06/2000'              |
      | LPM1_7YDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='22/06/2020'                 |
      | LPM1_7YDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='23/06/2021'                    |
      | LPM1_7YDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='24/06/2001'                   |
      | LPM1_7YDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='19/08/2022'  |
      | LPM1_10YDate_1    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='25/06/2019' |
      | LPM1_10YDate_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='26/06/1999'             |
      | LPM1_10YDate_3    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='27/06/2000'             |
      | LPM1_10YDate_4    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='28/06/2020'                |
      | LPM1_10YDate_5    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='29/06/2021'                   |
      | LPM1_10YDate_6    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='30/06/2001'                  |
      | LPM1_10YDate_7    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='25/08/2022' |
      | LPM1_SIDate_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_1  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='01/07/2019' |
      | LPM1_SIDate_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_2  from ft_w_wcri w where return_typ ='GrossAllFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='02/07/1999'             |
      | LPM1_SIDate_3     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_3  from ft_w_wcri w where return_typ ='GrossMgtFees' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='03/07/2000'             |
      | LPM1_SIDate_4     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_4  from ft_w_wcri w where return_typ ='GrossTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='04/07/2020'                |
      | LPM1_SIDate_5     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_5  from ft_w_wcri w where return_typ ='NetNAV' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='05/07/2021'                   |
      | LPM1_SIDate_6     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_6  from ft_w_wcri w where return_typ ='NetTWRR' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='06/07/2001'                  |
      | LPM1_SIDate_7     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate_7  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='01/09/2022' |