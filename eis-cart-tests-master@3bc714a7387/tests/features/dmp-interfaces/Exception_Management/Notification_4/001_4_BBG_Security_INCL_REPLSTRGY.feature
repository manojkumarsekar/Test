#base jira : https://jira.pruconnect.net/browse/EISDEV-6915

@gc_interface_securities
@dmp_regression_unittest
@exception_management
@notification_4
@eisdev_6915
@BBG_Security
@BBG_Security_REPLSTRGY
Feature: Exception Management | 4 | BBG Security | INCL with REPLSTRGY set
  Loading BBG Security with REPLSTRGY classification set and expecting INCL to get created on the fly and there is no Notfcn Id 4 exception

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
    And I assign "001_4_BBG_Security_INCL_REPLSTRGY.out" to variable "INPUT_FILENAME"

  Scenario: Load BBG Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect workflow is processed in DMP with success record count as "1"