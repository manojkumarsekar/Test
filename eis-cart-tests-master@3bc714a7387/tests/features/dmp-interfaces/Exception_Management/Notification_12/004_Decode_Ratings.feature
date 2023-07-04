#base jira : https://jira.pruconnect.net/browse/EISDEV-7103

@exception_management
@notification_12
@eisdev_7103
@decode
@decode_ratings
@gc_interface_decode
@dmp_regression_unittest

Feature: Exception Management | Load ratings from decode file
  Loading Decode file to create ratings in GS and expecting no error.

  Scenario: Initialize variables used across the feature file

      Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_12" to variable "INPUT_FILEPATH"
      And I assign "004_Decode_Ratings.xml" to variable "INPUT_FILENAME"

  Scenario: Load Decode file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_DECODE|

  Then I expect workflow is processed in DMP with total record count as "3"
  And success record count as "2"
  And filtered record count as "1"
