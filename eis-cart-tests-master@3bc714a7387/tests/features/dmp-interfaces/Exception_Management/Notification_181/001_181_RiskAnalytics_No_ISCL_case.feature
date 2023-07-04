#base jira : https://jira.pruconnect.net/browse/EISDEV-7296

@exception_management
@notification_181
@seisdev_7296
@gc_interface_risk_analytics
@dmp_regression_unittest

Feature: Exception Management | 181 | RISK_ANALYTICS | No ISCL No AICL case
  Loading Risk Analytics file with condition where ISCL does not get created
  Engine should not attempt creating AICL in this case and 181 should not be raised

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_181" to variable "INPUT_FILEPATH"
    And I assign "001_181_RiskAnalytics_No_ISCL_case.xml" to variable "INPUT_FILENAME"

  Scenario: Load Risk Analytics file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS|

  Then I expect workflow is processed in DMP with total record count as "1"
      Then I expect 0 exceptions are captured with the following criteria
        | NOTFCN_STAT_TYP | OPEN |
        | NOTFCN_ID       | 181  |