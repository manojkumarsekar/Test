#base jira : https://jira.pruconnect.net/browse/EISDEV-7119

@exception_management
@notification_15
@eisdev_7119
@TRDSS_TNC
@dmp_regression_unittest

Feature: Exception Management | 15 | Reuters Terms & Conditions | Original Expiry Date Format Product Fix
  Name change from Thomson Reuters Classification Scheme to Refinitiv Classification Scheme

  Loading Reuters TnC File expecting no error

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_15" to variable "INPUT_FILEPATH"
    And I assign "002_15_ReutersTnC_ProductFix.csv" to variable "INPUT_FILENAME"

  Scenario: Load Performance Returns file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions|

    Then I extract new job id from jblg table into a variable "JOB_ID"
        Then I expect 0 exceptions are captured with the following criteria
          | NOTFCN_STAT_TYP | OPEN |
          | NOTFCN_ID       | 15    |