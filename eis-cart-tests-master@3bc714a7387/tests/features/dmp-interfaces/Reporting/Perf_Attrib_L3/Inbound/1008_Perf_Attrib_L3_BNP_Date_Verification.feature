#https://jira.intranet.asia/browse/TOM-5192
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
#24/09/2019      TOM-5192    UAT issues fixes - inbound mapping changes for date format issue
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR4&title=Outbound+Data+Mapping+%3A-+L3+Attribution

@dw_interface_performance
@dmp_dw_regression
@tom_5192 @tom_5192_L3 @perf_attrib_l3 @eisdev_5525
Feature: Test BNP performance L3 file for verification of dates stored in database

  This is to test if BNP L3 Attribution file is getting loaded and test below scenarios
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
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "UPDATE_VAR_SYSDATE"

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/Perf_Attrib_L3/Inbound" to variable "testdata.path"

    #In order to make feature file re-runnable, existing L3 fund attribution & related data is cleaned up
    And I execute below query
    """
     ${testdata.path}/sql/1001_AccountBMSetup.sql
    """

  Scenario: Load BNP L3 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_ATTRIB_L3_DATE_VERIFICATION.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | PERF_ATTRIB_L3_DATE_VERIFICATION.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='7'
    """

  Scenario: Perform checks in WPEA for multiple scenarios for account returns

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "7":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications of dates in base and derived return types for all dates
      | Column            | Query                                                                                                                                                                                                                                                                               |
      | LAM3_Start_Date_1 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_1  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='10/05/2019' |
      | LAM3_Start_Date_2 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_2  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='12/12/2099' |
      | LAM3_Start_Date_3 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_3  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='03/05/2000' |
      | LAM3_Start_Date_4 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_4  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='04/05/2020' |
      | LAM3_Start_Date_5 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_5  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='05/05/2021' |
      | LAM3_Start_Date_6 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_6  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='06/05/2001' |
      | LAM3_Start_Date_7 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_Start_Date_7  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.PRD_START_TMS,'DD/MM/YYYY')='07/05/2022' |
      | LAM3_End_Date_1   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_1  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='01/10/2019'       |
      | LAM3_End_Date_2   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_2  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='02/06/2099'       |
      | LAM3_End_Date_3   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_3  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='03/06/2000'       |
      | LAM3_End_Date_4   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_4  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='04/06/2020'       |
      | LAM3_End_Date_5   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_5  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='05/06/2021'       |
      | LAM3_End_Date_6   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_6  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='06/06/2001'       |
      | LAM3_End_Date_7   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LAM3_End_Date_7  from ft_w_wpea w where ACCT_SOK_1 in (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='07/06/2022'       |