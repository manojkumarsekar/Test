#base jira : https://jira.pruconnect.net/browse/EISDEV-6954

@exception_management
@notification_163
@eisdev_6670
@eisdev_6954
@TRDSS_COMP
@TRDSS_COMP_withISN
@dmp_regression_unittest

Feature: Exception Management | 163 | TRDSS COMP | Load msg with ISN and without ISIN
  Loading file msg with ISN and without ISIN and expecting no failure

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_163" to variable "INPUT_FILEPATH"
    And I assign "007_163_ReutersComposite_wo_ISIN_with_ISN.csv" to variable "INPUT_FILENAME"

  Scenario: Load Reuters Composite file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |

  Then I expect workflow is processed in DMP with success record count as "1"