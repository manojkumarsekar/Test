# =================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 26/02/2019      TOM-3893    CDP SII Report - Swaps (Include new transaction type)
# 15/02/2020      EISDEV-7403 Performance improvement
# =================================================================================

@dw_interface_exchange_rates @dw_interface_portfolios @dw_interface_securities @dw_interface_transactions @dw_interface_reports
@too_slow
@dmp_dw_regression
@solvency @tom_3893 @eisdev_7403
Feature: Month-end CDP solvency reporting

  Reconcile CDP solvency report to expected output

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I assign "600" to variable "workflow.max.polling.time"

  Scenario: TC_1: Setup variables and replace batch IDs (to avoid deletions)

    # Some static data MDXs use a regex to extract date, thus additional numeric character (e.g. TC01) are avoided

    Given I assign "tests/test-data/dmp-interfaces/MonthEndReporting" to variable "MEtestdata.path"
    And I assign "${MEtestdata.path}/CDPSolvency" to variable "testdata.path"
    And I assign "CDP_Solvency_ESISODP_EXR_1_20180731.out" to variable "EXR_INPUT_FILENAME"
    And I assign "CDP_Solvency_ESIPME_PFL_20180731.out" to variable "PFL_INPUT_FILENAME"
    And I assign "CDP_Solvency_ESIPME_SEC_20180731.out" to variable "SEC_INPUT_FILENAME"
    And I assign "CDP_Solvency_ESIPME_TRN_20180731.out" to variable "TRN_INPUT_FILENAME"
    And I assign "cdp_solvency_TC_HK_output" to variable "PUBLISHING_HK_FILENAME"
    And I assign "cdp_solvency_TC_SG_output" to variable "PUBLISHING_SG_FILENAME"
    And I assign "cdp_solvency_TC_HK_output_OCT2018" to variable "PUBLISHING_HK_OCT2018_FILENAME"
    And I assign "cdp_solvency_TC_SG_output_OCT2018" to variable "PUBLISHING_SG_OCT2018_FILENAME"
    And I assign "/dmp/out/eis/solvency" to variable "PUBLISHING_DIR"

    And I execute below queries
    """
    DELETE ft_t_wagp WHERE LAST_DAY(rptg_prd_end_dte) = TO_DATE('31-JUL-2018','dd-mon-yyyy');
    DELETE ft_t_wfxr WHERE fx_dtdf_sok in (select dtdf_sok from ft_w_dtdf where substr(dtdf_sok,0,6) = '201807') and srce_curr_cde = 'GBP';
    DELETE ft_t_wtrd WHERE trd_dtdf_sok in (select dtdf_sok from ft_w_dtdf where substr(dtdf_sok,0,6) = '201807');
    commit
    """

  Scenario: TC_2: Load exchange rates

    Given I process "${testdata.path}/testdata/${EXR_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SOD_FX |

    Then I expect workflow is processed in DMP with total record count as "88"

  Scenario: TC_3: Load portfolios

    Given I process "${testdata.path}/testdata/${PFL_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PFL_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL   |

    Then I expect workflow is processed in DMP with total record count as "14"

  Scenario: TC_4: Load securities

    Given I process "${testdata.path}/testdata/${SEC_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SEC   |

    Then I expect workflow is processed in DMP with total record count as "20"

  Scenario: TC_5: Load Transactions

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${TRN_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${TRN_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_TRN   |

    Then I expect workflow is processed in DMP with total record count as "77"

  Scenario: TC_6: Publish HK report for forwards

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_HK_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                                                                         |
      | CONVERT_TO_EXCEL    | false                                                                                                                                                          |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                                                                              |
      | PUBLISHING_FILENAME | ${PUBLISHING_HK_FILENAME}.csv                                                                                                                                  |
      | THREAD_COUNT        | 1                                                                                                                                                              |
      | SQL_ID              | SELECT DISTINCT wtrd_sok id FROM ft_v_rpt1_cdp_trans_formatted WHERE me_date = TO_DATE('20180731','yyyymmdd') AND portfolio_group LIKE 'LIFE_CLIENT_GROUP_HK%' |
      | SQL_PUBLISH         | SELECT wtrd_sok id, flow_data FROM ft_v_rpt1_cdp_trans_formatted                                                                                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_HK_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_HK_FILENAME}.csv |

  Scenario: TC_7: Reconcile HK output for forwards

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_HK_FILENAME}.csv |
      | ExpectedFile | ${testdata.path}/outfiles/template/HK_reference.csv             |

  Scenario: Publish SG report for futures

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_SG_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                                                                         |
      | CONVERT_TO_EXCEL    | false                                                                                                                                                          |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                                                                              |
      | PUBLISHING_FILENAME | ${PUBLISHING_SG_FILENAME}.csv                                                                                                                                  |
      | THREAD_COUNT        | 1                                                                                                                                                              |
      | SQL_ID              | SELECT DISTINCT wtrd_sok id FROM ft_v_rpt1_cdp_trans_formatted WHERE me_date = TO_DATE('20180731','yyyymmdd') AND portfolio_group LIKE 'LIFE_CLIENT_GROUP_SG%' |
      | SQL_PUBLISH         | SELECT wtrd_sok id, flow_data FROM ft_v_rpt1_cdp_trans_formatted                                                                                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_SG_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_SG_FILENAME}.csv |

  Scenario: Reconcile SG output for futures

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_SG_FILENAME}.csv |
      | ExpectedFile | ${testdata.path}/outfiles/template/SG_reference.csv             |

  Scenario: TC_8: Publish HK report for swaps

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_HK_OCT2018_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                                                                         |
      | CONVERT_TO_EXCEL    | false                                                                                                                                                          |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                                                                              |
      | PUBLISHING_FILENAME | ${PUBLISHING_HK_OCT2018_FILENAME}.csv                                                                                                                          |
      | THREAD_COUNT        | 1                                                                                                                                                              |
      | SQL_ID              | SELECT DISTINCT wtrd_sok id FROM ft_v_rpt1_cdp_trans_formatted WHERE me_date = TO_DATE('20181031','yyyymmdd') AND portfolio_group LIKE 'LIFE_CLIENT_GROUP_HK%' |
      | SQL_PUBLISH         | SELECT wtrd_sok id, flow_data FROM ft_v_rpt1_cdp_trans_formatted                                                                                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_HK_OCT2018_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_HK_OCT2018_FILENAME}.csv |

  Scenario: TC_9: Reconcile HK output for swaps

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_HK_OCT2018_FILENAME}.csv |
      | ExpectedFile | ${testdata.path}/outfiles/template/HK_reference_OCT2018.csv             |

  Scenario: Publish SG report for swaps

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_SG_OCT2018_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                                                                         |
      | CONVERT_TO_EXCEL    | false                                                                                                                                                          |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                                                                              |
      | PUBLISHING_FILENAME | ${PUBLISHING_SG_OCT2018_FILENAME}.csv                                                                                                                          |
      | THREAD_COUNT        | 1                                                                                                                                                              |
      | SQL_ID              | SELECT DISTINCT wtrd_sok id FROM ft_v_rpt1_cdp_trans_formatted WHERE me_date = TO_DATE('20181031','yyyymmdd') AND portfolio_group LIKE 'LIFE_CLIENT_GROUP_SG%' |
      | SQL_PUBLISH         | SELECT wtrd_sok id, flow_data FROM ft_v_rpt1_cdp_trans_formatted                                                                                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_SG_OCT2018_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_SG_OCT2018_FILENAME}.csv |

  Scenario: Reconcile SG output for swaps

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_SG_OCT2018_FILENAME}.csv |
      | ExpectedFile | ${testdata.path}/outfiles/template/SG_reference_OCT2018.csv             |