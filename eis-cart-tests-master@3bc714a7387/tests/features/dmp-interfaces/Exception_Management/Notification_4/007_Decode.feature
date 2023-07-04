#base jira : https://jira.pruconnect.net/browse/EISDEV-7032

@exception_management
@notification_4
@eisdev_7032
@decode
@decode_gsdm_filter
@gc_interface_decode

Feature: Exception Management | 4 | F10 | test Decode Interface | GSDM Filter
  Loading Decode file to create industry classification in GS and expecting GSDM Filter does not load STR_PROD_STRUCT tag

  Scenario: Initialize variables used across the feature file

      Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
      And I assign "007_Decode.xml" to variable "INPUT_FILENAME"

  Scenario: Load Decode file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_DECODE|

  Then I expect workflow is processed in DMP with total record count as "6"
  And success record count as "5"
  And filtered record count as "1"
