#base jira : https://jira.pruconnect.net/browse/EISDEV-6689

@exception_management
@notification_21
@eisdev_6689
@gc_interface_issuer
@dmp_regression_unittest

Feature: Exception Management | 21 | BRS_ISSR | RTNG A3 | VD
  Loading BRS Issuer File with RTVL A3 and expecting no error in VD

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_21" to variable "INPUT_FILEPATH"
    And I assign "001_21_BRS_ISSR_RTVL_A3.xml" to variable "INPUT_FILENAME"

  Scenario: Load BRS Issuer Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER|

  Then I expect workflow is processed in DMP with success record count as "1"