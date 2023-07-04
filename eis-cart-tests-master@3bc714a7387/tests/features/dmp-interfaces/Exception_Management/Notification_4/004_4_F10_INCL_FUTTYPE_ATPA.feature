#base jira : https://jira.pruconnect.net/browse/EISDEV-6953

@exception_management
@notification_4
@eisdev_6953
@F10
@F10_missing_INCL
@dmp_regression_unittest

Feature: Exception Management | 4 | F10 | INCL with FUTTYPE-ATPA classification set
  Loading F10 with FUTTYPE-ATPA classification set and expecting no exceptions

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
    And I assign "004_4_F10_INCL_FUTTYPE_ATPA.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW|

  Then I expect workflow is processed in DMP with success record count as "1"