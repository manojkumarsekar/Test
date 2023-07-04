#base jira : https://jira.pruconnect.net/browse/EISDEV-6670

@gc_interface_reuters
@dmp_regression_unittest
@exception_management
@notification_163
@eisdev_6670
@TRDSS_COMP
@TRDSS_COMP_withRIC
Feature: Exception Management | 163 | TRDSS COMP | Resubmit msg with RIC
  Loading file with primary identifier RIC and expecting no failure

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_163" to variable "INPUT_FILEPATH"
    And I assign "004_163_ReutersComposite_withRIC.csv" to variable "INPUT_FILENAME"

  Scenario: Load Reuters Composite file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |

    Then I expect workflow is processed in DMP with success record count as "1"