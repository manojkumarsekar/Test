#https://jira.intranet.asia/browse/TOM-5144
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 20/09/2019      TOM-5144    UAT issues fixes - inbound mapping chnages for few columns and date format issue, asset class field made mandatory
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 22/12/2020      EISDEV-5173 Change in input file date format
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Performance+Data+Mart+-New

@dw_interface_performance
@dmp_dw_regression
@dmp_gs_upgrade
@tom_5144 @tom_5144_multiple_scenarios @perf_l1 @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file for value verification, checking derived & asset class scenario

  This is to test if BNP L1 performance file is getting loaded and test below scenarios
  1. 6M and 2Y values are stored correctly
  2. If derived values are not present in file, row should not be created in database
  3. If asset class is blank then load should fail

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
      | PERF_L1_Values_Verification.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | PERF_L1_Values_Verification.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for multiple scenarios

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and  DW_STATUS_NUM =1
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                        | Query                                                                                                                                                                                                                                                                                                                           |
      | LPM1_6MGrossAbsoluteReturn    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MGrossAbsoluteReturn  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.RETURN_6M_CAMT='0.080182921'           |
      | LPM1_6MGrossRelativeReturn    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MGrossRelativeReturn  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.RELV_RETURN_6M_CAMT='-0.01150918'      |
      | LPM1_2YGrossAbsoluteReturnAnn | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YGrossAbsoluteReturnAnn  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_2YR_RETURN_CAMT='0.037012821'    |
      | LPM1_2YGrossRelativeReturn    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YGrossRelativeReturn  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_2YR_RELV_RETURN_CAMT='-0.002669346' |
      | LPM1_Value_Date               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_Value_Date  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='31/05/2019'      |
      | LPM1_3M_Date                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3M_Date  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_1,'DD/MM/YYYY')='28/02/2019'     |
      | LPM1_6MDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_2,'DD/MM/YYYY')='30/11/2018'      |
      | LPM1_YTDDate                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_YTDDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_3,'DD/MM/YYYY')='31/12/2018'     |
      | LPM1_1YDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_1YDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_4,'DD/MM/YYYY')='31/05/2018'      |
      | LPM1_2YDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_5,'DD/MM/YYYY')='31/05/2017'      |
      | LPM1_3YDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_3YDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_6,'DD/MM/YYYY')='31/05/2016'      |
      | LPM1_5YDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_5YDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_7,'DD/MM/YYYY')='31/05/2014'      |
      | LPM1_7YDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_7YDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_8,'DD/MM/YYYY')='31/05/2012'      |
      | LPM1_10YDate                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_10YDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_9,'DD/MM/YYYY')='31/05/2012'     |
      | LPM1_SIDate                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_SIDate  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.USR_VAL_TMS_10,'DD/MM/YYYY')='30/05/2001'     |
      | LPM1_6MPriBenchmarkReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_6MPriBenchmarkReturn  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select ACCT_SOK from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.ACCT_2_RETURN_6M_CAMT='0.091692101'     |
      | LPM1_2YPriBenchmarkReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LPM1_2YPriBenchmarkReturnAnn  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select ACCT_SOK from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_2YR_ACCT_2_RET_CAMT='0.039682168' |

  Scenario: Load BNP L1 performance file for checking derived scenario

    #WCRI is deleted for both portfolio and benchmark as cleanup before loading
    Given I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'ALASPSTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
    """

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_L1_Derived_Return_Check.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | PERF_L1_Derived_Return_Check.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1           |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking derived scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and  DW_STATUS_NUM =1
    """

    Then I expect value of column "Derived_Value_Check" in the below SQL query equals to "0":
    """
      select COUNT(*) AS Derived_Value_Check from ft_w_wcri
      where dw_status_num =1
      and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1)
      AND RETURN_TYP in ('NetSalesChargeNAVGrossMgtFees',  'NetSalesChargeNAVGrossAllFees',  'NetSalesChrgNAVGrossAllFeesOrWthdgTaxes', 'NetSalesChargeTWRRGrossTWRR','NetSalesChargeNetTWRR','NetSalesChargeNetNAV')
    """

  Scenario: Load BNP L1 performance file for asset class check

    #WCRI is deleted for both portfolio and benchmark as cleanup before loading
    Given I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'ALASPSTST' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
    """

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_L1_Asset_Class_Check.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_L1_Asset_Class_Check.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_PARTIAL_CNT = '1'
    """

    And I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS NTEL_ROW_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fieldsAsset Class'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """