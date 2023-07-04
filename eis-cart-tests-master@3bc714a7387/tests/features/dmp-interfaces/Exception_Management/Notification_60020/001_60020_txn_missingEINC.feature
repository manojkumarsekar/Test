#base jira : https://jira.pruconnect.net/browse/EISDEV-6690

@gc_interface_transactions
@exception_management
@notification_163
@eisdev_6690
@TXN
@TXN_missingEINC
@dmp_regression_unittest
Feature: Exception Management | 60020 | TXN | missing EINC transaction type

  Loading TXN with missing EINC that is now inserted from backend(MAT:L:- and COLL::-)
  and expecting record gets processed successfully

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_60020" to variable "INPUT_FILEPATH"
    And I assign "001_60020_missingEINC_TRN_TYP.xml" to variable "INPUT_FILENAME"

  Scenario: Load TXN file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

    Then I expect workflow is processed in DMP with success record count as "1"