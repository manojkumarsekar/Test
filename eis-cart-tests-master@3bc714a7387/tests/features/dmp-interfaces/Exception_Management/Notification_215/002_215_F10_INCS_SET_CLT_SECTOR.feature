#base jira : https://jira.pruconnect.net/browse/EISDEV-6685

@exception_management
@notification_12
@eisdev_6685
@F10
@F10_INCS_SET_CLT_SECTOR
@gc_interface_securities
@dmp_regression_unittest

Feature: Exception Management | 215 | F10 | INCS SET_CLT_SECTOR
  Loading F10 Security with INCS SET_CLT_SECTOR and expecting no error

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_215" to variable "INPUT_FILEPATH"
    And I assign "002_215_F10_INCS_SET_CLT_SECTOR.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW|

  Then I expect workflow is processed in DMP with success record count as "1"