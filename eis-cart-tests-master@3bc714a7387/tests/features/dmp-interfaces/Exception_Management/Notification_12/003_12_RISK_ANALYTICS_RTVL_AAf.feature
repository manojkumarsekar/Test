#base jira : https://jira.pruconnect.net/browse/EISDEV-6673

@exception_management
@notification_12
@eisdev_6673
@risk_analytics_rtvl_AAf
@gc_interface_risk_analytics
@dmp_regression_unittest

Feature: Exception Management | 12 | RISK_ANALYTICS | RTVL AAf
  Loading Risk Analytics file with RTVL AAf and expecting no error

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_12" to variable "INPUT_FILEPATH"
    And I assign "003_12_RISK_ANALYTICS_RTVL_AAf.xml" to variable "INPUT_FILENAME"

  Scenario: Load Risk Analytics file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS|

  Then I expect workflow is processed in DMP with success record count as "1"