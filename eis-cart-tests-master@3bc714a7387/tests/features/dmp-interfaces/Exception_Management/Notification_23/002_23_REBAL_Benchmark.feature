#base jira : https://jira.pruconnect.net/browse/EISDEV-6686

@gc_interface_benchmark
@dmp_regression_unittest
@exception_management
@notification_23
@eisdev_6686

Feature: Exception Management | 23 | REBAL Benchmark | missing security
  Loading Rebal Benchmark file with security that is not present in GS ensuring there is no exception

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_23" to variable "INPUT_FILEPATH"
    And I assign "Snapshot_GMP_ASPLIF_20191202_0923879.csv" to variable "INPUT_FILENAME"

  Scenario: Load Rebal Benchmark file with security that is not present in GS ensuring there is no exception

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_REBAL_BENCHMARK |

    Then I expect workflow is processed in DMP with total record count as "3"
    Then I expect 0 exceptions are captured with the following criteria
      | MAIN_ENTITY_ID | GMP_ASPLIF:BES2ZY7VR |
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 23    |