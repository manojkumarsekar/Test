#base jira : https://jira.pruconnect.net/browse/EISDEV-7049

@exception_management
@notification_12
@eisdev_7049
@gc_interface_securities
@dmp_regression_unittest

Feature: Exception Management | 12 | BBG SECURITY | ERVL A *- | GC and VD
  Loading BBG Security with ERVL A *- and expecting no error in GC and VD

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_12" to variable "INPUT_FILEPATH"
    And I assign "002_12_BBG_SECURITY_ERVL.out" to variable "INPUT_FILENAME"

  Scenario: Load F10 Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY|

  Then I expect workflow is processed in DMP with success record count as "1"