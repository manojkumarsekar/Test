#base jira : https://jira.pruconnect.net/browse/EISDEV-7224

@exception_management
@notification_23
@eisdev_7224
@gc_interface_securities
@dmp_regression_integrationtest

Feature: Exception Management | 23 | BNP Security | MD ID
  Loading BNP Security with MD ID and then BNP SOD Positions and expecting no error

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_23" to variable "INPUT_FILEPATH"
    And I assign "001_23_BNP_SECURITY_MD_ID.out" to variable "INPUT_FILENAME_1"
    And I assign "001_23_BNP_POSITIONS_MD_ID.out" to variable "INPUT_FILENAME_2"

  Scenario: Load BNP Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME_1}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY|

  Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load BNP Positions file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME_2}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM|

  Then I expect workflow is processed in DMP with success record count as "1"