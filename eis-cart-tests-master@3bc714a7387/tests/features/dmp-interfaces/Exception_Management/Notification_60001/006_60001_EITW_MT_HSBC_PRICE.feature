#base jira : https://jira.pruconnect.net/browse/EISDEV-7270

@gc_interface_prices
@dmp_regression_unittest
@exception_management
@notification_60001
@eisdev_7270

Feature: Exception Management | 60001 | HSBC TW Price | blank MKT_PRICE
  Loading HSBC TW Price with blank MKT_PRICE and expecting record to get filtered

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_60001" to variable "INPUT_FILEPATH"
    And I assign "006_60001_EITW_MT_HSBC_PRICE.csv" to variable "INPUT_FILENAME"

  Scenario: Load HSBC TW Price file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  |  EITW_MT_HSBC_PRICE |

    Then I expect workflow is processed in DMP with filtered record count as "1"