#base jira : https://jira.pruconnect.net/browse/EISDEV-6670

@gc_interface_securities
@dmp_regression_unittest
@exception_management
@notification_163
@eisdev_6670
@F10
@F10_defaultMarket
Feature: Exception Management | 163 | F10 | default market as ZZZZ
  Loading F10 without EXCHANGE or EXCHANGE_MIC and expecting record is successfully created using default market identifier as ZZZZ

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_163" to variable "INPUT_FILEPATH"
    And I assign "001_163_F10_NoMarket.xml" to variable "INPUT_FILENAME"

  Scenario: Load F10 file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with success record count as "1"