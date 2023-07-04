#base jira : https://jira.pruconnect.net/browse/EISDEV-6670

@gc_interface_securities
@exception_management
@notification_163
@eisdev_6670
@F10
@F10_missingEISTinVD
@dmp_regression_unittest

Feature: Exception Management | 163 | F10 | EQUITY_WARRANT domain value in VD
  Loading file with instrument type EQUITY_WARRANT and expecting no exception from VD

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_163" to variable "INPUT_FILEPATH"
    And I assign "002_163_F10_missingEISTinVD.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with success record count as "1"