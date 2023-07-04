#base jira : https://jira.pruconnect.net/browse/EISDEV-6953

@exception_management
@notification_4
@eisdev_6953
@txn
@txn_Decode_missing_INCL
@dmp_regression_integrationtest

Feature: Exception Management | 4 | F10 | test Decode Interface | INCL with BRSBROKRES-TWM classification set
  Loading Decode file to create industry classification in GS and then
  Loading txn with BRSBROKRES-TWM classification set and expecting no exceptions

  Scenario: Initialize variables used across the feature file

      Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
      And I assign "005_4_Decode_BRSBROKRES_TWM.xml" to variable "INPUT_FILENAME"

  Scenario: Load Decode file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_DECODE|

  Then I expect workflow is processed in DMP with success record count as "4"

  Scenario: Initialize variables used across the feature file

      Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_4" to variable "INPUT_FILEPATH"
      And I assign "005_4_txn_INCL_BRSBROKRES_TWM.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION|

  Then I expect workflow is processed in DMP with success record count as "1"