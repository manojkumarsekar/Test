#base jira : https://jira.pruconnect.net/browse/EISDEV-7053

@exception_management
@notification_4
@eisdev_7053
@F10
@F10_missing_INCL
@dmp_regression_unittest
@gc_interface_securities

Feature: Exception Management | 4 | F10 | INCL with MNSECTOR-General purpose/public impt classification
  Loading F10 with MNSECTOR-General purpose/public classification set and expecting no Notfcn 4 exceptions

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
    And I assign "008_4_F10_INCL_MNSECTOR.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW|

  Then I extract new job id from jblg table into a variable "JOB_ID"
      Then I expect 0 exceptions are captured with the following criteria
        | NOTFCN_STAT_TYP | OPEN |
        | NOTFCN_ID       | 4    |