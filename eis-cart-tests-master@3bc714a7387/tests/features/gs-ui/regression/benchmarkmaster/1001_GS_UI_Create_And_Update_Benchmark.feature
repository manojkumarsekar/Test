#EISDEV-7458 : Disable drools for MainEntityID and MainEntityIdCtxtTyp and move to java rule to suppress additional changes shown for those 2 fields on UI

@gc_ui_benchmark
@web @gs_ui_regression @eisdev_7458
Feature: Update Benchmark
  This feature file can be used to check the benchmark update functionality over UI.
  This handles both the maker checker event require to update benchmark.
  It checks if BNENTYP and BNENID is created in BNST

  Scenario: TC_1: Create Benchmark
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a benchmark with following details
      | ESI Benchmark Name        | TEST_GAA_${VAR_RANDOM} |
      | Official Benchmark Name   | SGX Benchmark          |
      | Benchmark Category        | Fixed                  |
      | Currency                  | SGD-Singapore Dollar   |
      | Hedged/Unhedged Indicator | O - Original           |
      | Rebalance Frequency       | AN - Annually          |
      | Benchmark Level Access    | Country Level          |
      | Benchmark Provider Name   | UOB                    |
      | CRTS Benchmark Code       | CRTSCD_${VAR_RANDOM}   |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TEST_GAA_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST_GAA_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Benchmark "TEST_GAA_${VAR_RANDOM}" is created

    Then I expect value of column "BNENTYP_CREATE_VERIFICATION" in the below SQL query equals to "PASS":
    """
      select case when count(1) = 1 then 'PASS' else 'FAIL' end BNENTYP_CREATE_VERIFICATION
      from ft_t_bnid crtscode, ft_t_bnid eisautobnchid, ft_t_bnst bnst
      where crtscode.bnchmrk_id_ctxt_typ = 'CRTSCODE' and crtscode.bnchmrk_id = 'CRTSCD_${VAR_RANDOM}'
      and crtscode.end_tms is null and eisautobnchid.bnchmrk_id_ctxt_typ = 'EISAUTOBNCHID'
      and eisautobnchid.bnch_oid = crtscode.bnch_oid and eisautobnchid.end_tms is null
      and eisautobnchid.bnch_oid = bnst.bnch_oid and bnst.stat_def_id = 'BNENTYP'
      and eisautobnchid.bnchmrk_id_ctxt_typ = bnst.stat_char_val_txt
    """

    Then I expect value of column "BNENID_CREATE_VERIFICATION" in the below SQL query equals to "PASS":
    """
      select case when count(1) = 1 then 'PASS' else 'FAIL' end BNENID_CREATE_VERIFICATION
      from ft_t_bnid crtscode, ft_t_bnid eisautobnchid, ft_t_bnst bnst
      where crtscode.bnchmrk_id_ctxt_typ = 'CRTSCODE' and crtscode.bnchmrk_id = 'CRTSCD_${VAR_RANDOM}'
      and crtscode.end_tms is null and eisautobnchid.bnchmrk_id_ctxt_typ = 'EISAUTOBNCHID'
      and eisautobnchid.bnch_oid = crtscode.bnch_oid and eisautobnchid.end_tms is null
      and eisautobnchid.bnch_oid = bnst.bnch_oid and bnst.stat_def_id = 'BNENID'
      and eisautobnchid.bnchmrk_id = bnst.stat_char_val_txt
    """


  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Update Banchmark

    Given I login to golden source UI with "task_assignee" role

    When I update benchmark "TEST_GAA_${VAR_RANDOM}" with following details
      | Benchmark Level Access  | Sector Level |
      | Benchmark Provider Name | CRISIL       |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TEST_GAA_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST_GAA_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect the Benchmark "TEST_GAA_${VAR_RANDOM}" is updated as below
      | Benchmark Level Access  | Sector Level |
      | Benchmark Provider Name | CRISIL       |

  Scenario: Close browsers
    Then I close all opened web browsers
