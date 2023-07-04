#base jira : https://jira.pruconnect.net/browse/EISDEV-7117

@exception_management
@notification_15
@eisdev_7117
@gc_interface_performance_returns
@dmp_regression_unittest

Feature: Exception Management | 15 | Performance Returns | Comma Separated Benchmark Name

  Loading Performance Returns File with Comma separated Benchmark Name and expecting no error

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_15" to variable "INPUT_FILEPATH"
    And I assign "001_15_Performance_Returns.csv" to variable "INPUT_FILENAME"

  Scenario: Load Performance Returns file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_PERFORMANCE_RETURNS|

  Then I expect workflow is processed in DMP with success record count as "1"