#base jira : https://jira.pruconnect.net/browse/EISDEV-7170

@gc_interface_cash
@dmp_regression_unittest
@exception_management
@notification_60001
@eisdev_7170
@eisdev_7170_CASH_TXN

Feature: Exception Management | 60001 | Cash Transaction | 0 Amount
  Loading Cash Transaction with 0 amount and expecting record to get filtered

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_60001" to variable "INPUT_FILEPATH"
    And I assign "001_60001_TAC_CASH_TXN.csv" to variable "INPUT_FILENAME"

  Scenario: Load Cash Txn file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  |  ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION |

    Then I expect workflow is processed in DMP with filtered record count as "1"