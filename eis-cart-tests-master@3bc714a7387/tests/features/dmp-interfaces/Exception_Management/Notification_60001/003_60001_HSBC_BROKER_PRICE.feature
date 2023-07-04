#base jira : https://jira.pruconnect.net/browse/EISDEV-7170

@gc_interface_prices
@dmp_regression_unittest
@exception_management
@notification_60001
@eisdev_7170
@eisdev_7170_HSBC

Feature: Exception Management | 60001 | HSBC Broker Price | blank CLIENT_ID
  Loading HSBC Broker Price with blank CLIENT_ID and expecting record to get filtered

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_60001" to variable "INPUT_FILEPATH"
    And I assign "003_60001_HSBC_BROKER_PRICE.xml" to variable "INPUT_FILENAME"

  Scenario: Load HSBC Broker Price file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  |  EIS_MT_DMP_HSBC_BROKER_PRICE |

    Then I expect workflow is processed in DMP with filtered record count as "1"