#https://jira.intranet.asia/browse/TOM-5198

@ignore @tom_5198 @web @gs_ui_regression @reporting_dmp_ui @web_pending @gc_ui_benchmark
Feature: This feature is to test the creation of Benchmark through Benchmark UI screen with the newly added field for Reporting - BNP Performance Benchmark Flag

  Scenario: TC_1: Create Benchmark
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a benchmark with following details
      | ESI Benchmark Name             | TEST_5198_${VAR_RANDOM} |
      | Official Benchmark Name        | SGX Benchmark           |
      | Benchmark Category             | Fixed                   |
      | Currency                       | SGD-Singapore Dollar    |
      | Hedged/Unhedged Indicator      | O - Original            |
      | Rebalance Frequency            | AN - Annually           |
      | Benchmark Level Access         | Country Level           |
      | Benchmark Provider Name        | UOB                     |
      | CRTS Benchmark Code            | CRTSCD_${VAR_RANDOM}    |
      | BNP Performance Benchmark Flag | CRTSCD_${VAR_RANDOM}    |

    And I save changes

    Then I expect a record in My WorkList with entity name "TEST_5198_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST_5198_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Benchmark "TEST_5198_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers