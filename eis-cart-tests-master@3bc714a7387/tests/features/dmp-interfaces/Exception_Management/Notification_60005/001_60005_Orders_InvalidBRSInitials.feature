#base jira : https://jira.pruconnect.net/browse/EISDEV-6916

@gc_interface_orders
@exception_management
@notification_60005
@eisdev_6916
@eisdev_6684
@invalid_initial_orders
@dmp_regression_unittest

Feature: Exception Management | 60005 | Orders | invalid BRS Initials
  Loading Order file with invalid BRS initials and expecting record gets processed successfully

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_60005" to variable "INPUT_FILEPATH"
    And I assign "001_60005_Orders_InvalidBRSInitials.xml" to variable "INPUT_FILENAME"

  Scenario: Load Orders file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS |

    Then I expect workflow is processed in DMP with success record count as "1"