# ===================================================================================================================================================================================
# Date            JIRA          Comments
# ===================================================================================================================================================================================
# 09/11/2020      EISDEV-6588   The following columns are added
#    Dop Cash Flow :
#    ---------------
#    DOP_CASH_DOP_VS_ACTUAL_PORTFOLIO_CRTS_ID - Link the DOP portfolio and actual portfolio, it saves into FT_T_ACCR where RL_TYP=DOPAPPRT
#    DOP_CASH_TARGET_PERCENT - Target percentage value, it saves into ft_t_fnvd.trgt_alloc_cpct
#    DOP_CASH_LOWER_TOLERANCE_PERCENT - Lower percentage value, it saves into ft_t_fnvd.Min_shr_camt
#    DOP_CASH_UPPER_TOLERANCE_PERCENT - Upper percentage value, it saves into ft_t_fnvd.Max_shr_camt

#    DOP Drifted Benchmark Mapping : (New Sheet created as BenchmarkLink)
#    -------------------------------
#    PARENT_CRTS_ID_FOR_BM - It is lookup to map the Account and benchmark
#    DOP_DRFTBNCH_ALADDIN_BENCHMARK_CODE or DOP_DRFTBNCH_CRTS_ID - Benchmark Aladdin code or CRTS ID
# ===================================================================================================================================================================================

@gc_interface_portfolios
@dmp_regression_unittest
@eisdev_6588 @001_portfolio_dop_cashflow @001_portfolio_dop_benchmak
Feature: Portfolio Uploader | DOP | Cash Flow Tolerance | Drifted Benchmark

  Additional attribute required in Golden source portfolio master GUI and portfolio master upload,
  This feature file is to test create or update these fields (DOP_CASH_DOP_VS_ACTUAL_PORTFOLIO_CRTS_ID, DOP_CASH_TARGET_PERCENT,
  DOP_CASH_LOWER_TOLERANCE_PERCENT, DOP_CASH_UPPER_TOLERANCE_PERCENT, PARENT_CRTS_ID_FOR_BM, DOP_DRFTBNCH_ALADDIN_BENCHMARK_CODE
  and DOP_DRFTBNCH_CRTS_ID)

  Scenario: Initialize variables and Deactivate Existing test accounts to maintain clean state before executing tests

    Given I assign "003_DMP_R3_PortfolioMasteringTemplate_Final_4.14.xlsx" to variable "INPUT_FILENAME"
    And I assign "003_DMP_R3_PortfolioMasteringTemplate_Final_4.14_Update.xlsx" to variable "INPUT_FILENAME_FOR_UPDATE"
    And I assign "tests/test-data/dmp-interfaces/Portfolio/Inbound" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query to "deactivate the existing records, so that we can validate the insert and update"
     """
     ${testdata.path}/sql/003_Portfolio_Uploader_DOP_CFE_DriftedBM_Deactivate_Old_Data.sql
     """

  Scenario: Process Portfolio Master template to create new DOP Cashflow, Drifted benchmark and verify its processed successfully

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "3"
    And fail record count as "0"

  Scenario:  Verify relationship between DOP vs Actual portfolio created in FT_T_ACCR table WHERE rl_typ=DOPAPPRT
    Then I expect value of column "accr_count" in the below SQL query equals to "1":
    """
    select count(0) as accr_count
    from ft_t_accr where rl_typ='DOPAPPRT' and end_tms is null
    and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null)
    and rep_acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGPPMT' and acct_id_ctxt_typ='CRTSID' and end_tms is null)
    """

  Scenario:  Verify DOP cash flow tolerance created in FT_T_FNVD table
    Then I expect value of column "fnvd_count" in the below SQL query equals to "1":
    """
    select count(0) as fnvd_count from ft_t_fnvd where end_tms is null and
    fnvs_oid in (select fnvs_oid from ft_t_fnvs where end_tms is null and  fnch_oid in (select fnch_oid from ft_t_fnch where end_tms is null and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null)))
    and min_shr_camt=0.1
    and max_shr_camt=1
    and trgt_alloc_cpct=0.5
    """

  Scenario:  Verify relationship between Drifted benchmarks and account created in FT_T_ABMR table WHERE rl_typ=DRFTBNCH
    Then I expect value of column "abmr_count" in the below SQL query equals to "2":
    """
    select count(0) abmr_count  from ft_t_abmr where rl_typ='DRFTBNCH' and end_tms is null
    and acct_id in (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='AGSACA' AND ACCT_ID_CTXT_TYP='CRTSID' and end_tms is null)
    and bnch_oid in (select bnch_oid from ft_t_BNID where BNCHMRK_ID_CTXT_TYP in 'BRSBNCHID' and BNCHMRK_ID in ('SAA_ASSPLT','NDRVDFCOMP') and end_tms is null)
    """

  Scenario: Process Portfolio Master template to update existing DOP Cashflow and verify its processed successfully

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_FOR_UPDATE}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_FOR_UPDATE}         |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "3"
    And fail record count as "0"

  Scenario:  Verify relationship between DOP vs Actual portfolio updated in FT_T_ACCR table WHERE rl_typ=DOPAPPRT
    Then I expect value of column "accr_count" in the below SQL query equals to "1":
    """
    select count(0) as accr_count
    from ft_t_accr where rl_typ='DOPAPPRT' and end_tms is null
    and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null)
    and rep_acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='ALHKEF' and acct_id_ctxt_typ='CRTSID' and end_tms is null)
    """

  Scenario:  Verify DOP cash flow tolerance updated in FT_T_FNVD table
    Then I expect value of column "fnvd_count" in the below SQL query equals to "1":
    """
    select count(0) as fnvd_count from ft_t_fnvd where end_tms is null and
    fnvs_oid in (select fnvs_oid from ft_t_fnvs where end_tms is null and  fnch_oid in (select fnch_oid from ft_t_fnch where end_tms is null and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null)))
    and min_shr_camt=1
    and max_shr_camt=5
    and trgt_alloc_cpct=3
    """