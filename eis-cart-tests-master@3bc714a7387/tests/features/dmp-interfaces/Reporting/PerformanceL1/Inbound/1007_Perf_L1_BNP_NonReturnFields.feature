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
@tom_4930 @tom_4930_NonReturnFields @tom_5143 @perf_l1 @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file for non return columns

  This is to test if BNP L1 performance file is getting loaded in DWH for  for non return columns  are stored correctly

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
      | PERF_L1_GrossAllFeesOrWthdgTaxes.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | PERF_L1_GrossAllFeesOrWthdgTaxes.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1               |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
      """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                   | Query                                                                                                                                                                                                                                                                                                                                                                   |
      | ACCT_2_RETURN_1M_CAMT    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_2_RETURN_1M_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.ACCT_2_RETURN_1M_CAMT='0.00482368'                                                  |
      | ACCT_2_RETURN_3M_CAMT    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_2_RETURN_3M_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.ACCT_2_RETURN_3M_CAMT='0.01080821'                                                  |
      | ACCT_2_RETURN_6M_CAMT    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_2_RETURN_6M_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.ACCT_2_RETURN_6M_CAMT='0.044984078'                                                 |
      | AN_10YR_ACCT_2_RET_CAMT  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AN_10YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_10YR_ACCT_2_RET_CAMT='0.044984010'                                             |
      | AS_OF_TMS                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AS_OF_TMS  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and to_char(w.AS_OF_TMS,'DD/MM/YYYY')='31/05/2019'                                                    |
      | AN_2YR_ACCT_2_RET_CAMT   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AN_2YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_2YR_ACCT_2_RET_CAMT='0.009158368'                                               |
      | AN_3YR_ACCT_2_RET_CAMT   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AN_3YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_3YR_ACCT_2_RET_CAMT='0.00915'                                                   |
      | AN_5YR_ACCT_2_RET_CAMT   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AN_5YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_5YR_ACCT_2_RET_CAMT='0.00915178'                                                |
      | AN_7YR_ACCT_2_RET_CAMT   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AN_7YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_7YR_ACCT_2_RET_CAMT='0.080121'                                                  |
      | AN_SI_ACCT_2_RET_CAMT    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AN_SI_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.AN_SI_ACCT_2_RET_CAMT='0.01150918'                                                  |
      | CUM_10YR_ACCT_2_RET_CAMT | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CUM_10YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.CUM_10YR_ACCT_2_RET_CAMT='0.037012821'                                           |
      | CUM_1YR_ACCT_2_RET_CAMT  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CUM_1YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.CUM_1YR_ACCT_2_RET_CAMT='0.08092921'                                              |
      | CUM_3YR_ACCT_2_RET_CAMT  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CUM_3YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.CUM_3YR_ACCT_2_RET_CAMT='0.0150918'                                               |
      | CUM_5YR_ACCT_2_RET_CAMT  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CUM_5YR_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.CUM_5YR_ACCT_2_RET_CAMT='0.0189071'                                               |
      | CUM_SI_ACCT_2_RET_CAMT   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CUM_SI_ACCT_2_RET_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.CUM_SI_ACCT_2_RET_CAMT='0.00512021'                                                |
      | YTD_ACCT_2_RETURN_CAMT   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTD_ACCT_2_RETURN_CAMT  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.YTD_ACCT_2_RETURN_CAMT='0.0560121'                                                 |
      | USR_CHAR_VAL_TXT_9       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS USR_CHAR_VAL_TXT_9  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_9='25% JACI + 75% Markit iBoxx ALBI ex China Taiwan Net Cust'         |
      | USR_CHAR_VAL_TXT_10      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS USR_CHAR_VAL_TXT_10  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_10 is null                                                           |
      | ACCT_SOK_2               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_SOK_2  from ft_w_wcri w where return_typ ='GrossAllFeesOrWthdgTaxes' and acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 = 'AGOCABTST' and  DW_STATUS_NUM =1) and dw_status_num =1 and w.ACCT_SOK_2=(select acct_sok from FT_T_WACT where INTRNL_ID1 = 'ALASPSTST' AND DW_STATUS_NUM=1) |

