#base jira : https://jira.pruconnect.net/browse/EISDEV-7027

@gc_interface_securities
@dmp_regression_unittest
@exception_management
@notification_215
@eisdev_7027
@eisdev_6685
@F10
@F10_SectorSource_P
Feature: Exception Management | 215 | F10 | Sector Source as P
  Loading F10 Sector Source as P and expecting incl is filtered out for P and msgs loaded successfully.

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_215" to variable "INPUT_FILEPATH"
    And I assign "001_215_F10_SectorSource_P.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with success record count as "1"