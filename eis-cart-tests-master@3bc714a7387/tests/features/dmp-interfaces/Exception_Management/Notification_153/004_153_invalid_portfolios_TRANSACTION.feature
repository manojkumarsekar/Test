#base jira : https://jira.pruconnect.net/browse/EISDEV-6905

@gc_interface_transactions
@dmp_regression_unittest
@exception_management
@notification_153
@eisdev_6905
@invalid_portfolio
@invalid_portfolio_txn
Feature: Exception Management | 153 | TRANSACTION | invalid portfolio
  Loading TRANSACTION with invalid portfolio and expecting record should be filtered

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_153" to variable "INPUT_FILEPATH"
    And I assign "004_153_invalid_portfolios_TRANSACTION.xml" to variable "INPUT_FILENAME"

  Scenario: Load TRANSACTION file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 26   |