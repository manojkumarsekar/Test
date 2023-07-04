#base jira : https://jira.pruconnect.net/browse/EISDEV-6670

@gc_interface_reuters
@dmp_regression_unittest
@exception_management
@notification_163
@eisdev_6670
@TRDSS_TNC
@TRDSS_TNC_woRIC

Feature: Exception Management | 163 | TRDSS TnC | filter msg without RIC
  Loading file without primary identifier RIC and expecting no failure
  This message will have severity code as 0

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_163" to variable "INPUT_FILEPATH"
    And I assign "005_163_ReutersTnC_woRIC.csv" to variable "INPUT_FILENAME"

  Scenario: Load Reuters Teams and conditions file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I expect workflow is processed in DMP with success record count as "1"