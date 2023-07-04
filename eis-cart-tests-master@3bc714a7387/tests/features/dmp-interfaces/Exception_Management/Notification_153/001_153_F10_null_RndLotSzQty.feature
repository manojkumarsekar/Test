#base jira : https://jira.pruconnect.net/browse/EISDEV-6668

@gc_interface_securities
@dmp_regression_unittest
@exception_management
@notification_153
@eisdev_6668
@F10
@F10_null_RndLotSzQty
Feature: Exception Management | 153 | F10 | null RND_LOT_SZ_CQTY in MKIS case
  Loading F10 file with null RND_LOT_SZ_CQTY in MKIS and ensuring there is no NullPointerException

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_153" to variable "INPUT_FILEPATH"
    And I assign "001_153_F10_null_RndLotSzQty.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file with null RND_LOT_SZ_CQTY in MKIS and ensure there is no NullPointerException failure

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_STAT_TYP | OPEN |
      | NOTFCN_ID       | 2    |