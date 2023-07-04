@web @gs_ui_regression @my_worklist_reject
@gc_ui_benchmark @gc_ui_worklist

Feature: My Worklist testing for Reject Request

  This feature file can be used to check the My Worklist functionality over UI.

  Scenario: Reject request

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I create a benchmark with following details
      | ESI Benchmark Name        | GAA2_SGP225_${VAR_RANDOM} |
      | Official Benchmark Name   | SGX Benchmark             |
      | Benchmark Category        | Fixed                     |
      | Currency                  | SGD-Singapore Dollar      |
      | Hedged/Unhedged Indicator | A - Pending Active        |
      | Rebalance Frequency       | AN - Annually             |
      | Benchmark Level Access    | Country Level             |
      | Benchmark Provider Name   | UOB                       |
      | CRTS Benchmark Code       | CRTSCD_${VAR_RANDOM}      |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I reject a record from My WorkList with entity name "GAA2_SGP225_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect a record in My WorkList with entity name "GAA2_SGP225_${VAR_RANDOM}" and status "Rejected"

  Scenario: Close browsers
    Then I close all opened web browsers