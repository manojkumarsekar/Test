#base jira : https://jira.pruconnect.net/browse/EISDEV-6914

@exception_management
@notification_4
@eisdev_6914
@TRDSS_TNC
@TRDSS_TNC_missing_INCL
@dmp_regression_unittest

Feature: Exception Management | 4 | TRDSS TnC | INCL with RTORSBTY-OTR classification set
  Loading F10 with SAL-HEAI classification set and expecting no exceptions

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
    And I assign "006_4_ReutersTnC_INCL_RTORSBTY_OTR.xml" to variable "INPUT_FILENAME"

  Scenario: Load TRDSS_TNC file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions|

  Then I expect workflow is processed in DMP with success record count as "1"