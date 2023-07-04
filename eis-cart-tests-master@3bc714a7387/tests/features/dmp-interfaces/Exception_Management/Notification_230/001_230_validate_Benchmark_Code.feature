#base jira : https://jira.pruconnect.net/browse/EISDEV-6671

@gc_interface_portfolios
@dmp_regression_unittest
@exception_management
@notification_230
@notification_60001
@eisdev_6671
@validate_benchmark_code

Feature: Exception Management | 230 | PORTFOLIO | validate benchmark code
  Loading PORTFOLIO with invalid benchmark id and expecting specified error message

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_230" to variable "INPUT_FILEPATH"
    And I assign "001_230_validate_Benchmark_Code.xml" to variable "INPUT_FILENAME"

  Scenario: Load PORTFOLIO file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |

    Then I expect workflow is processed in DMP with total record count as "1"
    Then I expect 1 exceptions are captured with the following criteria
      | MSG_SEVERITY_CDE | 30 |
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 60016   |
      | PARM_VAL_TXT |User defined Error thrown! . DMP Benchmark Code: IBALBSGC is differing from BRS Benchmark Code: BM_IBALSG|
    Then I expect 1 exceptions are captured with the following criteria
      | MSG_SEVERITY_CDE | 40 |
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 60001   |
      | PARM_VAL_TXT |User defined Error thrown! . DMP Benchmark Code: IBALBSGC is differing from BRS Benchmark Code: BM_IBALSG|