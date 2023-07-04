#https://jira.intranet.asia/browse/TOM-4971
#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 09/09/2019      TOM-4971    Development - BNP Performance L3 file Load
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# ===================================================================================================================================================================================


@dw_interface_performance
@dmp_dw_regression
@tom_4971 @tom_4971_insertonefundload @perf_attrib_l3 @dmp_gs_upgrade @eisdev_5525
Feature: Test BNP performance L3 file for 1 fund full data load

  This is to test if BNP L3 performance file is getting loaded in DWH for fund full data load

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/Perf_Attrib_L3/Inbound" to variable "testdata.path"

    And I execute below query
    """
     DELETE ft_t_wpea WHERE acct_sok_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ABTHMF' and  DW_STATUS_NUM =1);
    """

    And I execute below query
    """
     ${testdata.path}/sql/AccountBMSetuponefundfullload.sql
    """

  Scenario: TC_3: Load BNP L3 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_1_fund_fullload.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_1_fund_fullload.csv      |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1466'
      """

  Scenario: TC_4: Perform checks in WPEA for multiple scenarios

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "1354":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ABTHMF' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "1466":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ABTHMF' and  DW_STATUS_NUM =1)
    """

  Scenario: TC_5: Delete WACR created as part of setup

    Then I execute below query
    """
     delete ft_t_wacr where WACR_SOK = (select WACR_SOK from FT_T_WACR where RL_TYP = 'BL3PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'ALAIEFTST' AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1);
    """