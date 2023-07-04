#base jira : https://jira.pruconnect.net/browse/EISDEV-6692

@gc_interface_securities
@dmp_regression_unittest
@exception_management
@notification_4
@eisdev_6915
@F10
@F10_missing_INCL
Feature: Exception Management | 4 | F10 | INCL with SAL-HEAI classification set
  Loading F10 with SAL-HEAI classification set and expecting no exceptions

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
    And I assign "002_4_F10_INCL_SAL_HEAI.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with success record count as "1"