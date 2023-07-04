#base jira : https://jira.pruconnect.net/browse/EISDEV-6980

@exception_management
@notification_12
@eisdev_6673
@eisdev_6980
@F10
@F10_RTNG_70
@gc_interface_securities
@dmp_regression_unittest

Feature: Exception Management | 12 | F10 | RTNG 70 | VD
  Loading F10 Security with RTNG 70 and expecting no error in VD

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_12" to variable "INPUT_FILEPATH"
    And I assign "001_12_F10_RTNG_70.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW|

  Then I expect workflow is processed in DMP with success record count as "1"