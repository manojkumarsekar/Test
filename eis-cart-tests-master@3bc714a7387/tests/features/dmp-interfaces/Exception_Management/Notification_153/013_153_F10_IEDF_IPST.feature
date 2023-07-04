#base jira : https://jira.pruconnect.net/browse/EISDEV-7308

@gc_interface_securities
@dmp_regression_unittest
@exception_management
@notification_153
@eisdev_7308
@F10

Feature: Exception Management | 153 | F10 | IEDF_IPST INTFLR_PRINFLR_PRCONVT
  Loading F10 file with no IEDF condition and ensuring there is no IPST parent child relation violation Exception

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_153" to variable "INPUT_FILEPATH"
    And I assign "013_153_F10_IEDF_IPST.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"
    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 153    |