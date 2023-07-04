#https://jira.intranet.asia/browse/TOM-5263

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 20/09/2019      TOM-5263    Remaining data fields to be mapped for BNP L1 file load to CORIC Outbound files
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 22/12/2020      EISDEV-5173 Change in input file date format
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Performance+Data+Mart+-New

@dw_interface_performance
@dmp_dw_regression
@tom_5263 @perf_l1 @l1rem_gross @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file for verification of Remaining attributes not mapped as part of MVP for Gross
  As part of this feature file we are doing field level testing for all 120 fields mapped

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "UPDATE_VAR_SYSDATE"

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/PerformanceL1/Inbound" to variable "testdata.path"

    #In order to make feature file re-runnable, existing fund performance & related data is cleaned up
    And I execute below query
    """
     ${testdata.path}/sql/L1_RemainingFields_AccountBMSetup.sql
    """

  Scenario: Load BNP L1 performance file having 1 record which is expected to create 5 rows in WCRI

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | L1_Perf_AllDataPoints_GrossAllFeesWithhdgTax.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                                  |
      | FILE_PATTERN  | L1_Perf_AllDataPoints_GrossAllFeesWithhdgTax.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1                           |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for multiple scenarios

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "5":
  """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax'
      and  DW_STATUS_NUM =1) AND DW_STATUS_NUM =1 and USR_CHAR_VAL_TXT_7 = 'Test1' and USR_VAL_TMS_11=to_date('30/10/2018','dd/mm/yyyy')
      and USR_VAL_TMS_12 = to_date('31/05/2018','dd/mm/yyyy')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                                            | Query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      #Remove 6 Month Fund Net Absolute Return - Primary Benchmark
      | M6FundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M6FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and RETURN_6M_CAMT='22.1'                       |

      #Remove 6 Month Fund Net Absolute Return - Secondary Benchmark
      | M6FundNetIncludingSalesChargeAbsoluteReturn_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M6FundNetIncludingSalesChargeAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and RETURN_6M_CAMT='22.1'                       |

      #FYTD Fund Net Return - Primary Benchmark
      | FYTDFundNetAbsoluteReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundNetAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_RETURN_CAMT='32.1'                                       |

      #FYTD Fund Net Return - Secondary Benchmark
      | FYTDFundNetAbsoluteReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundNetAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_RETURN_CAMT='32.1'                                       |

      #FYTD Fund Gross Return - Primary Benchmark
      | FYTDFundGrossAbsoluteReturn_1                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and FYTD_RETURN_CAMT='34.1'                                           |

      #FYTD Fund Gross Return - Secondary Benchmark
      | FYTDFundGrossAbsoluteReturn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and FYTD_RETURN_CAMT='34.1'                                           |

      #FYTD Fund Gross Return - Secondary Benchmark
      | FYTDFundGrossAbsoluteReturn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and FYTD_RETURN_CAMT='34.1'                                           |

      #FYTD Fund Benchmark Return - Primary Benchmark
      | FYTDFundPriBenchmarkReturn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundPriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and FYTD_ACCT_2_RETURN_CAMT='35.1'                                     |
      | FYTDFundPriBenchmarkReturn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundPriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_ACCT_2_RETURN_CAMT='35.1'                               |

      #FYTD Fund Benchmark Return - Secondary Benchmark
      | FYTDFundSecBenchmarkReturn_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundSecBenchmarkReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and FYTD_ACCT_2_RETURN_CAMT='39.1'                                     |
      | FYTDFundSecBenchmarkReturn_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundSecBenchmarkReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_ACCT_2_RETURN_CAMT='39.1'                               |

      #FYTD Fund Net Relative Return - Primary Benchmark
      | FYTDFundNetRelativeReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_RELV_RETURN_CAMT='36.1'                                  |

      #FYTD Fund Net Relative Return - Secondary Benchmark
      | FYTDFundNetIncludingSalesChargeRelativeReturn_2   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundNetIncludingSalesChargeRelativeReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_RELV_RETURN_CAMT='40.1'              |

      #FYTD Fund Gross Relative Return - Primary Benchmark
      | FYTDFundGrossRelativeReturn_1                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and FYTD_RELV_RETURN_CAMT='40.1'                                |

      #FYTD Fund Gross Relative Return - Secondary Benchmark
      | FYTDFundGrossRelativeReturnSecondaryBenchmark_2   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FYTDFundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and FYTD_RELV_RETURN_CAMT='41.1'                    |

      #YTD Fund Benchmark Return - Secondary Benchmark
      | YTDFundSecBenchmarkReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundSecBenchmarkReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and YTD_ACCT_2_RETURN_CAMT='49.1'                                       |
      | YTDFundSecBenchmarkReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundSecBenchmarkReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and YTD_ACCT_2_RETURN_CAMT='49.1'                                 |

      #2Y Fund Benchmark Return - Primary Benchmark
      | Y2PriBenchmarkReturn_1                            | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2PriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_2YR_ACCT_2_RET_CAMT='65.1'                                           |
      | Y2PriBenchmarkReturn_1                            | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2PriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_ACCT_2_RET_CAMT='65.1'                                     |

      #2Y Fund Benchmark Return - Secondary Benchmark
      | Y2BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_2YR_ACCT_2_RET_CAMT='69.1'                                     |
      | Y2BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_ACCT_2_RET_CAMT='69.1'                               |

      #2Y Fund Benchmark Return Ann - Secondary Benchmark
      | Y2FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_2YR_ACCT_2_RET_CAMT='79.1'                                     |
      | Y2FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_ACCT_2_RET_CAMT='79.1'                               |

      #3Y Fund Benchmark Return - Secondary Benchmark
      | Y3BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_3YR_ACCT_2_RET_CAMT='89.1'                                     |
      | Y3BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_3YR_ACCT_2_RET_CAMT='89.1'                               |

      #3Y Fund Benchmark Return Ann - Secondary Benchmark
      | Y3FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_3YR_ACCT_2_RET_CAMT='99.1'                                     |
      | Y3FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_3YR_ACCT_2_RET_CAMT='99.1'                               |

      #4Y Fund Benchmark Return - Primary Benchmark
      | Y4PriBenchmarkReturn_1                            | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4PriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_4YR_ACCT_2_RET_CAMT='105.1'                                          |
      | Y4PriBenchmarkReturn_1                            | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4PriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_ACCT_2_RET_CAMT='105.1'                                    |

      #4Y Fund Benchmark Return - Secondary Benchmark
      | Y4BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_4YR_ACCT_2_RET_CAMT='109.1'                                    |
      | Y4BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_ACCT_2_RET_CAMT='109.1'                              |

      #4Y Fund Benchmark Return Ann- Primary Benchmark
      | Y4FundPriBenchmarkReturnAnn_1                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundPriBenchmarkReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_4YR_ACCT_2_RET_CAMT='115.1'                                    |
      | Y4FundPriBenchmarkReturnAnn_1                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundPriBenchmarkReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_ACCT_2_RET_CAMT='115.1'                              |

      #4Y Fund Benchmark Return Ann - Secondary Benchmark
      | Y4FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_4YR_ACCT_2_RET_CAMT='119.1'                                    |
      | Y4FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_ACCT_2_RET_CAMT='119.1'                              |

      #5Y Fund Benchmark Return - Secondary Benchmark
      | Y5BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_5YR_ACCT_2_RET_CAMT='129.1'                                    |
      | Y5BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_5YR_ACCT_2_RET_CAMT='129.1'                              |

      #5Y Fund Benchmark Return Ann - Secondary Benchmark
      | Y5FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_5YR_ACCT_2_RET_CAMT='139.1'                                    |
      | Y5FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_5YR_ACCT_2_RET_CAMT='139.1'                              |
      #Remove | Y5FundSecBenchmarkReturnAnn_2                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_5YR_ACCT_2_RET_CAMT='139.1'                 |

      #7Y Fund Benchmark Return - Primary Benchmark
      | Y7PriBenchmarkReturn_1                            | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7PriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_7YR_ACCT_2_RET_CAMT='145.1'                                          |
      | Y7PriBenchmarkReturn_1                            | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7PriBenchmarkReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_ACCT_2_RET_CAMT='145.1'                                    |

      #7Y Fund Benchmark Return - Secondary Benchmark
      | Y7BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_7YR_ACCT_2_RET_CAMT='149.1'                                    |
      | Y7BenchmarkReturnSecondary_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_ACCT_2_RET_CAMT='149.1'                              |

      #7Y Fund Benchmark Return Ann - Secondary Benchmark
      | Y7FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_7YR_ACCT_2_RET_CAMT='159.1'                                    |
      | Y7FundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_7YR_ACCT_2_RET_CAMT='159.1'                              |

      #10Y Fund Benchmark Return - Secondary Benchmark
      | Y10BenchmarkReturnSecondary_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_10YR_ACCT_2_RET_CAMT='169.1'                                  |
      | Y10BenchmarkReturnSecondary_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10BenchmarkReturnSecondary_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_10YR_ACCT_2_RET_CAMT='169.1'                            |

      #10Y Fund Benchmark Return Ann - Secondary Benchmark
      | Y10FundSecBenchmarkReturnAnn_2                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_10YR_ACCT_2_RET_CAMT='179.1'                                  |
      | Y10FundSecBenchmarkReturnAnn_2                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_10YR_ACCT_2_RET_CAMT='179.1'                            |

      #SI Fund Benchmark Return - Secondary Benchmark
      | SIFundSecBenchmarkReturn_2                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundSecBenchmarkReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_SI_ACCT_2_RET_CAMT='189.1'                                       |
      | SIFundSecBenchmarkReturn_2                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundSecBenchmarkReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_SI_ACCT_2_RET_CAMT='189.1'                                 |

      #SI Fund Benchmark Return Ann - Secondary Benchmark
      | SIFundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_SI_ACCT_2_RET_CAMT='199.1'                                     |
      | SIFundSecBenchmarkReturnAnn_2                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundSecBenchmarkReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_SI_ACCT_2_RET_CAMT='199.1'                               |

      #Y2 Fund Net Return - Primary Benchmark
      | Y2FundNetAbsoluteReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_RETURN_CAMT='62.1'                                      |

      #Y2 Fund Net Return - Secondary Benchmark
      | Y2FundNetAbsoluteReturn_2                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_RETURN_CAMT='62.1'                                      |

      #Y2 Fund Net Return Ann- Primary Benchmark
      | Y2FundNetAbsoluteReturnAnn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_RETURN_CAMT='72.1'                                    |

      #Y2 Fund Net Return Ann - Secondary Benchmark
      | Y2FundNetAbsoluteReturnAnn_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetAbsoluteReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_RETURN_CAMT='72.1'                                    |

      #Y4 Fund Net Return - Primary Benchmark
      | Y4FundNetAbsoluteReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_RETURN_CAMT='102.1'                                     |

      #Y4 Fund Net Return - Secondary Benchmark
      | Y4FundNetAbsoluteReturn_2                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_RETURN_CAMT='102.1'                                     |

      #Y4 Fund Net Return Ann - Primary Benchmark
      | Y4FundNetAbsoluteReturnAnn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_RETURN_CAMT='112.1'                                   |

      #Y4 Fund Net Return Ann- Secondary Benchmark
      | Y4FundNetAbsoluteReturnAnn_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetAbsoluteReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_RETURN_CAMT='112.1'                                   |

      #YTD Fund Net Relative Return Secondary Benchmark
      | YTDFundNetRelativeReturnSecondaryBenchmark_2      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and YTD_RELV_RETURN_CAMT='50.1'                  |

      #YTD Fund Gross Relative Return Secondary Benchmark
      | YTDFundGrossRelativeReturnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and YTD_RELV_RETURN_CAMT='51.1'                      |

      #1Y Fund Net Relative Return Secondary Benchmark
      | Y1FundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y1FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_1YR_RELV_RETURN_CAMT='60.1'               |

      #2Y Fund Net Including Sales Charge Absolute Return
      | Y2FundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_RETURN_CAMT='63.1'         |

      #2Y Fund Gross Absolute Return
      | Y2FundGrossAbsoluteReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_2YR_RETURN_CAMT='64.1'                                          |

      #2Y Fund Net Relative Return
      | Y2FundNetRelativeReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_RELV_RETURN_CAMT='66.1'                                 |

      #2Y Fund Net Including Sales Charge Relative Return
      | Y2FundNetIncludingSalesChargeRelativeReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_RELV_RETURN_CAMT='67.1'    |

      #2Y Fund Gross Relative Return
      | Y2FundGrossRelativeReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_2YR_RELV_RETURN_CAMT='68.1'                                     |

      #2Y Fund Net Relative Return Secondary Benchmark
      | Y2FundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_2YR_RELV_RETURN_CAMT='70.1'               |

      #2Y Fund Gross Relative Return Secondary Benchmark
      | Y2FundGrossRelativeReturnSecondaryBenchmark_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_2YR_RELV_RETURN_CAMT='71.1'                   |

      #2Y Fund Net Including Sales Charge Absolute Return (Ann.)
      | Y2FundNetIncludingSalesChargeAbsoluteReturnAnn_1  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetIncludingSalesChargeAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_RETURN_CAMT='73.1'       |

      #2Y Fund Net Relative Return (Ann.)
      | Y2FundNetRelativeReturnAnn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_RELV_RETURN_CAMT='76.1'                               |

      #2Y Fund Net Including Sales Charge Relative Return (Ann.)
      | Y2FundNetIncludingSalesChargeRelativeReturnAnn_1  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetIncludingSalesChargeRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_RELV_RETURN_CAMT='77.1'  |

      #2Y Fund Net Relative Return (Ann) Secondary Benchmark
      | Y2FundNetRelativeReturnAnnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_2YR_RELV_RETURN_CAMT='80.1'             |

      #2Y Fund Gross Relative Return (Ann) Secondary Benchmark
      | Y2FundGrossRelativeReturnAnnSecondaryBenchmark_2  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y2FundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_2YR_RELV_RETURN_CAMT='81.1'                 |

      #3Y Fund Net Including Sales Charge Absolute Return
      | Y3FundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_3YR_RETURN_CAMT='83.1'         |

      #3Y Fund Gross Absolute Return
      | Y3FundGrossAbsoluteReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_3YR_RETURN_CAMT='84.1'                                          |
      | Y3FundGrossAbsoluteReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_3YR_RETURN_CAMT='84.1'                                          |

      #3Y Fund Net Relative Return
      | Y3FundNetRelativeReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_3YR_RELV_RETURN_CAMT='86.1'                                 |

      #3Y Fund Net Including Sales Charge Relative Return
      | Y3FundNetIncludingSalesChargeRelativeReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_3YR_RELV_RETURN_CAMT='87.1'    |

      #3Y Fund Gross Relative Return
      | Y3FundGrossRelativeReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_3YR_RELV_RETURN_CAMT='88.1'                                     |

      #3Y Fund Net Relative Return Secondary Benchmark
      | Y3FundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_3YR_RELV_RETURN_CAMT='90.1'               |

      #3Y Fund Gross Relative Return Secondary Benchmark
      | Y3FundGrossRelativeReturnSecondaryBenchmark_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_3YR_RELV_RETURN_CAMT='91.1'                   |

      #3Y Fund Net Relative Return (Ann) Secondary Benchmark
      | Y3FundNetRelativeReturnAnnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_3YR_RELV_RETURN_CAMT='100.1'            |

      #3Y Fund Gross Relative Return (Ann) Secondary Benchmark
      | Y3FundGrossRelativeReturnAnnSecondaryBenchmark_2  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_3YR_RELV_RETURN_CAMT='101.1'                |

      #4Y Fund Net Including Sales Charge Absolute Return
      | Y4FundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_RETURN_CAMT='103.1'        |

      #4Y Fund Gross Absolute Return
      | Y4FundGrossAbsoluteReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_4YR_RETURN_CAMT='104.1'                                         |
      | Y4FundGrossAbsoluteReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_4YR_RETURN_CAMT='104.1'                                         |

      #4Y Fund Net Relative Return
      | Y4FundNetRelativeReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_RELV_RETURN_CAMT='106.1'                                |

      #4Y Fund Net Including Sales Charge Relative Return
      | Y4FundNetIncludingSalesChargeRelativeReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_RELV_RETURN_CAMT='107.1'   |

      #4Y Fund Gross Relative Return
      | Y4FundGrossRelativeReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_4YR_RELV_RETURN_CAMT='108.1'                                    |

      #4Y Fund Net Relative Return Secondary Benchmark
      | Y4FundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_4YR_RELV_RETURN_CAMT='110.1'              |

      #4Y Fund Gross Relative Return Secondary Benchmark
      | Y4FundGrossRelativeReturnSecondaryBenchmark_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_4YR_RELV_RETURN_CAMT='111.1'                  |

      #4Y Fund Net Including Sales Charge Absolute Return (Ann.)
      | Y4FundNetIncludingSalesChargeAbsoluteReturnAnn_1  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetIncludingSalesChargeAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_RETURN_CAMT='113.1'      |

      #4Y Fund Gross Absolute Return (Ann.)
      | Y4FundGrossAbsoluteReturnAnn_1                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_4YR_RETURN_CAMT='114.1'                                       |
      | Y4FundGrossAbsoluteReturnAnn_2                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossAbsoluteReturnAnn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_4YR_RETURN_CAMT='114.1'                                       |

      #4Y Fund Net Relative Return (Ann.)
      | Y4FundNetRelativeReturnAnn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_RELV_RETURN_CAMT='116.1'                              |

      #4Y Fund Net Including Sales Charge Relative Return (Ann.)
      | Y4FundNetIncludingSalesChargeRelativeReturnAnn_1  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetIncludingSalesChargeRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_RELV_RETURN_CAMT='117.1' |

      #4Y Fund Gross Relative Return (Ann.)
      | Y4FundGrossRelativeReturnAnn_1                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_4YR_RELV_RETURN_CAMT='118.1'                                  |

      #4Y Fund Net Relative Return (Ann) Secondary Benchmark
      | Y4FundNetRelativeReturnAnnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_4YR_RELV_RETURN_CAMT='120.1'            |

      #4Y Fund Gross Relative Return (Ann) Secondary Benchmark
      | Y4FundGrossRelativeReturnAnnSecondaryBenchmark_2  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y4FundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_4YR_RELV_RETURN_CAMT='121.1'                |

      #5Y Fund Net Including Sales Charge Absolute Return
      | Y5FundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_5YR_RETURN_CAMT='123.1'        |

      #5Y Fund Gross Absolute Return
      | Y5FundGrossAbsoluteReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_5YR_RETURN_CAMT='124.1'                                         |
      | Y5FundGrossAbsoluteReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_5YR_RETURN_CAMT='124.1'                                         |

      #5Y Fund Net Relative Return
      | Y5FundNetRelativeReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_5YR_RELV_RETURN_CAMT='126.1'                                |

      #5Y Fund Net Including Sales Charge Relative Return
      | Y5FundNetIncludingSalesChargeRelativeReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_5YR_RELV_RETURN_CAMT='127.1'   |

      #5Y Fund Gross Relative Return
      | Y5FundGrossRelativeReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_5YR_RELV_RETURN_CAMT='128.1'                                    |

      #5Y Fund Net Relative Return Secondary Benchmark
      | Y5FundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_5YR_RELV_RETURN_CAMT='130.1'              |

      #5Y Fund Gross Relative Return Secondary Benchmark
      | Y5FundGrossRelativeReturnSecondaryBenchmark_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_5YR_RELV_RETURN_CAMT='131.1'                  |

      #5Y Fund Net Relative Return (Ann) Secondary Benchmark
      | Y5FundNetRelativeReturnAnnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_5YR_RELV_RETURN_CAMT='140.1'            |

      #5Y Fund Gross Relative Return (Ann) Secondary Benchmark
      | Y5FundGrossRelativeReturnAnnSecondaryBenchmark_2  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_5YR_RELV_RETURN_CAMT='141.1'                |

      #7Y Fund Net Absolute Return
      | Y7FundNetAbsoluteReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_RETURN_CAMT='142.1'                                     |
      | Y7FundNetAbsoluteReturn_2                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_RETURN_CAMT='142.1'                                     |

      #7Y Fund Net Including Sales Charge Absolute Return
      | Y7FundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_RETURN_CAMT='143.1'        |

      #7Y Fund Gross Absolute Return
      | Y7FundGrossAbsoluteReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_7YR_RETURN_CAMT='144.1'                                         |
      | Y7FundGrossAbsoluteReturn_2                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_7YR_RETURN_CAMT='144.1'                                         |

      #7Y Fund Net Relative Return
      | Y7FundNetRelativeReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_RELV_RETURN_CAMT='146.1'                                |

      #7Y Fund Net Including Sales Charge Relative Return
      | Y7FundNetIncludingSalesChargeRelativeReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_RELV_RETURN_CAMT='147.1'   |

      #7Y Fund Gross Relative Return
      | Y7FundGrossRelativeReturn_1                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_7YR_RELV_RETURN_CAMT='148.1'                                    |

      #7Y Fund Net Relative Return Secondary Benchmark
      | Y7FundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_7YR_RELV_RETURN_CAMT='150.1'              |

      #7Y Fund Gross Relative Return Secondary Benchmark
      | Y7FundGrossRelativeReturnSecondaryBenchmark_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_7YR_RELV_RETURN_CAMT='151.1'                  |

      #7Y Fund Net Absolute Return (Ann.)
      | Y7FundNetAbsoluteReturnAnn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_7YR_RETURN_CAMT='152.1'                                   |

      #7Y Fund Net Including Sales Charge Absolute Return (Ann.)
      | Y7FundNetIncludingSalesChargeAbsoluteReturnAnn_1  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetIncludingSalesChargeAbsoluteReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_7YR_RETURN_CAMT='153.1'      |

      #7Y Fund Net Relative Return (Ann.)
      | Y7FundNetRelativeReturnAnn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_7YR_RELV_RETURN_CAMT='156.1'                              |

      #7Y Fund Net Including Sales Charge Relative Return (Ann.)
      | Y7FundNetIncludingSalesChargeRelativeReturnAnn_1  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetIncludingSalesChargeRelativeReturnAnn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and AN_7YR_RELV_RETURN_CAMT='157.1' |

      #7Y Fund Net Relative Return (Ann) Secondary Benchmark
      | Y7FundNetRelativeReturnAnnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_7YR_RELV_RETURN_CAMT='160.1'            |

      #7Y Fund Gross Relative Return (Ann) Secondary Benchmark
      | Y7FundGrossRelativeReturnAnnSecondaryBenchmark_2  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y7FundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_7YR_RELV_RETURN_CAMT='161.1'                |

      #10Y Fund Net Including Sales Charge Absolute Return
      | Y10FundNetIncludingSalesChargeAbsoluteReturn_1    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_10YR_RETURN_CAMT='163.1'      |

      #10Y Fund Gross Absolute Return
      | Y10FundGrossAbsoluteReturn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_10YR_RETURN_CAMT='164.1'                                       |
      | Y10FundGrossAbsoluteReturn_2                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossAbsoluteReturn_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_10YR_RETURN_CAMT='164.1'                                       |

      #10Y Fund Net Relative Return
      | Y10FundNetRelativeReturn_1                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_10YR_RELV_RETURN_CAMT='166.1'                              |

      #10Y Fund Net Including Sales Charge Relative Return
      | Y10FundNetIncludingSalesChargeRelativeReturn_1    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_10YR_RELV_RETURN_CAMT='167.1' |

      #10Y Fund Gross Relative Return
      | Y10FundGrossRelativeReturn_1                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_10YR_RELV_RETURN_CAMT='168.1'                                  |

      #10Y Fund Net Relative Return Secondary Benchmark
      | Y10FundNetRelativeReturnSecondaryBenchmark_2      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_10YR_RELV_RETURN_CAMT='170.1'            |

      #10Y Fund Gross Relative Return Secondary Benchmark
      | Y10FundGrossRelativeReturnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_10YR_RELV_RETURN_CAMT='171.1'                |

      #10Y Fund Net Relative Return (Ann) Secondary Benchmark
      | Y10FundNetRelativeReturnAnnSecondaryBenchmark_2   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_10YR_RELV_RETURN_CAMT='180.1'          |

      #10Y Fund Gross Relative Return (Ann) Secondary Benchmark
      | Y10FundGrossRelativeReturnAnnSecondaryBenchmark_2 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_10YR_RELV_RETURN_CAMT='181.1'              |

      #SI Fund Net Including Sales Charge Absolute Return
      | SIFundNetIncludingSalesChargeAbsoluteReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundNetIncludingSalesChargeAbsoluteReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_SI_RETURN_CAMT='183.1'         |

      #SI Fund Net Relative Return
      | SIFundNetRelativeReturn_1                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundNetRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_SI_RELV_RETURN_CAMT='186.1'                                 |

      #SI Fund Net Including Sales Charge Relative Return
      | SIFundNetIncludingSalesChargeRelativeReturn_1     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundNetIncludingSalesChargeRelativeReturn_1 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BMGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetSalesChrgNAVGrossAllFeesOrWthdgTaxes' and CUM_SI_RELV_RETURN_CAMT='187.1'    |

      #SI Fund Net Relative Return Secondary Benchmark
      | SIFundNetRelativeReturnSecondaryBenchmark_2       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundNetRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and CUM_SI_RELV_RETURN_CAMT='190.1'               |

      #SI Fund Gross Relative Return Secondary Benchmark
      | SIFundGrossRelativeReturnSecondaryBenchmark_2     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundGrossRelativeReturnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and CUM_SI_RELV_RETURN_CAMT='191.1'                   |

      #SI Fund Net Relative Return (Ann) Secondary Benchmark
      | SIFundNetRelativeReturnAnnSecondaryBenchmark_2    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundNetRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='NetNAVGrossAllFeesOrWthdgTaxes' and AN_SI_RELV_RETURN_CAMT='200.1'             |

      #SI Fund Gross Relative Return (Ann) Secondary Benchmark
      | SIFundGrossRelativeReturnAnnSecondaryBenchmark_2  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundGrossRelativeReturnAnnSecondaryBenchmark_2 from ft_w_wcri w where dw_status_num =1 and acct_sok_2 = (select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'BSGRFEEWT004' AND DW_STATUS_NUM=1) and acct_sok= (select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'AUTO_TST_PFL004_GrossAllFeesWtdgTax' AND DW_STATUS_NUM=1) and return_typ ='GrossAllFeesOrWthdgTaxes' and AN_SI_RELV_RETURN_CAMT='201.1'                 |