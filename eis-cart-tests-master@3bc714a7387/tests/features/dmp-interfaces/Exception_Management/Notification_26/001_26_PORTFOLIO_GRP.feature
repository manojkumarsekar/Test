#base jira : https://jira.pruconnect.net/browse/EISDEV-7089
#base jira : https://jira.pruconnect.net/browse/EISDEV-7104

@gc_interface_portfolios
@dmp_regression_unittest
@exception_management
@notification_26
@eisdev_7089
@eisdev_7104
@eisdev_7150

Feature: Exception Management | 26 | PORTFOLIO GROUP | invalid portfolio
  Loading PORTFOLIO GROUP with invalid portfolio and expecting no exceptions

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_26" to variable "INPUT_FILEPATH"
    And I assign "001_26_PORTFOLIO_GRP.xml" to variable "INPUT_FILENAME"

  Scenario: Load PORTFOLIO GROUP file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with total record count as "2"
    Then I expect workflow is processed in DMP with success record count as "1"
    Then I expect workflow is processed in DMP with filtered record count as "1"

    Then I extract new job id from jblg table into a variable "JOB_ID"
    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 26   |