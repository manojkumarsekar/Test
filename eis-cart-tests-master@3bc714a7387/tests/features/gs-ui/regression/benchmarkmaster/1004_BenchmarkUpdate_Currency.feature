#JiraLink: https://jira.pruconnect.net/browse/EISDEV-7487
@gc_ui_benchmark
@eisdev_7487 @web @gs_ui_regression
Feature: Update Benchmark for MP_ASPLIF
  This feature file can be used to check the benchmark update functionality over UI for MP_ASPLIF.
  This handles both the maker checker event require to update benchmark.

  Scenario: TC_1: Update Currency Field

    Given I login to golden source UI with "task_assignee" role

    When I update benchmark "MP_ASPLIF" with following details
      | Currency                  | USD-US Dollar   |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "MP_ASPLIF"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "MP_ASPLIF"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect the Benchmark "MP_ASPLIF" is updated as below
      | Currency                  | USD-US Dollar   |

