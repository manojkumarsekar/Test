#base jira : https://jira.pruconnect.net/browse/EISDEV-7103

@exception_management
@notification_12
@eisdev_7103
@risk_analytics_invalid_rating
@gc_interface_risk_analytics
@dmp_regression_unittest

Feature: Exception Management | 12 | RISK_ANALYTICS | RTNG TEST
  Loading Risk Analytics file with RTVL TEST and expecting error with specific message

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_12" to variable "INPUT_FILEPATH"
    And I assign "005_12_RISK_ANALYTICS_invalid_rating.xml" to variable "INPUT_FILENAME"

  Scenario: Load Risk Analytics file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS|

  Then I extract new job id from jblg table into a variable "JOB_ID"
      Then I expect 1 exceptions are captured with the following criteria
        | NOTFCN_STAT_TYP | OPEN |
        | NOTFCN_ID       | 12   |
        | PARM_VAL_TXT       | ICRISSU CC1 BRS RatingValue   |