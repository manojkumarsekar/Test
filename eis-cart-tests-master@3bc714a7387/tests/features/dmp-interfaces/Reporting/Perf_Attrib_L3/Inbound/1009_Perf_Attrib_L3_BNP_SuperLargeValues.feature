#https://jira.pruconnect.net/browse/EISDEV-7455
#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New

@dw_interface_performance
@dmp_dw_regression
@perf_attrib_l3 @eisdev_7455

Feature: Test attribution file for Super Large values

  This is to test BNP L3 attribution file containing super large values for Portfolio Return (base), Bench Return (base) & Active Return (base)
  columns does not raise exception and the input record gets stored in WPEA table with the columns containing large values as null

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

    #Accout and Benchmark Creation
    And I execute below query
    """
     ${testdata.path}/sql/AccountBMSetup.sql
    """

  Scenario: TC_2: Load BNP L3 performance file

    Given I process "${testdata.path}/testdata/1009_PERF_LARGE_VALUES_L3.csv" file with below parameters
      | FILE_PATTERN  | 1009_PERF_LARGE_VALUES_L3.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |
      | BUSINESS_FEED |                               |

    Then I expect workflow is processed in DMP with total record count as "2"
    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: TC_3: Verify data in WPEA

    Then I expect value of column "WPEA_COUNT_1" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT_1
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1 and AS_OF_DTDF_SOK = '20191130'
      and ACCT_2_BASE_RET_CAMT = '8.832915448' and ACCT_1_BASE_RET_CAMT is null and BASE_ACTV_RET_CAMT is null
    """

    Then I expect value of column "WPEA_COUNT_2" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT_2
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'ALAIEFTST' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1 and AS_OF_DTDF_SOK = '20201231'
      and ACCT_2_BASE_RET_CAMT is null and ACCT_1_BASE_RET_CAMT = '88000000000000000000' and BASE_ACTV_RET_CAMT is null
    """