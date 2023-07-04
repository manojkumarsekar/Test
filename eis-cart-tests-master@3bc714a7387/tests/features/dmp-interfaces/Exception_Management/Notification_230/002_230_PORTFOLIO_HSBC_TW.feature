#base jira : https://jira.pruconnect.net/browse/EISDEV-7223

@gc_interface_portfolios
@dmp_regression_unittest
@exception_management
@notification_230
@eisdev_7223

Feature: Exception Management | 230 | PORTFOLIO | fins id HSBCTW
  Loading PORTFOLIO with fins id HSBCTW and expecting no error as we have transformed the value to HSBC TW.

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_230" to variable "INPUT_FILEPATH"
    And I assign "002_230_PORTFOLIO_HSBC_TW.xml" to variable "INPUT_FILENAME"

  Scenario: Load PORTFOLIO file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |

   Then I expect workflow is processed in DMP with success record count as "1"