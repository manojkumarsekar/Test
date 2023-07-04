#https://jira.intranet.asia/browse/TOM-4971
#https://jira.intranet.asia/browse/TOM-5204
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 09/09/2019      TOM-4971    Development - BNP Performance L3 file Load
# 27/09/2019      TOM-5204    adjst tms mapping changed from sysdate to Value Date field
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# 27/02/2020      EISDEV-5564  Active Return(local) and Active Contribution field mappings
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New

@dw_interface_performance
@dmp_dw_regression
@tom_4971 @tom_4971_insert @perf_attrib_l3 @tom_5204 @eisdev_5525 @eisdev_5564
Feature: Test BNP performance L3 file for insert

  This is to test if BNP L3 performance file is getting loaded in DWH for insert

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
      | 1001_PERF_INSERT_L3.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | 1001_PERF_INSERT_L3.csv       |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
      """

  Scenario: TC_3: Perform checks in WPEA for multiple scenarios

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

    Then I expect value of column "WPEA_COUNT_adjsttms" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT_adjsttms
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1 and to_char(adjst_tms,'DD/MM/YYYY')='31/07/2019'
    """

    Then I expect value of column "WPEA_COUNT_activereturnlocal" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT_activereturnlocal
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1 and LOCAL_ACTV_RET_CAMT = '-0.027'
    """

    Then I expect value of column "WPEA_COUNT_activecontrib" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT_activecontrib
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1 and ACTIVE_CONTR_TO_RET_CAMT = '-0.069962262'
    """