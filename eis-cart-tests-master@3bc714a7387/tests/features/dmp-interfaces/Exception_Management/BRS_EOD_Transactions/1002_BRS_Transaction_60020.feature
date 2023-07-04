#base jira : https://jira.pruconnect.net/browse/EISDEV-6582

@gc_interface_transactions
@dmp_regression_unittest
@eisdev_6582
Feature: Verify Exception For BRS Transaction is not raised for missing classification

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/BRS_EOD_Transactions/inputfiles" to variable "testdata.path"
    And I assign "brs_trn_6582.xml" to variable "INPUT_FILENAME_BRS"

    And I execute below query to "Update existing EXTR.TRD_ID to new oid"
	"""
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID() WHERE TRD_ID LIKE '%AUTO%';
    COMMIT
    """

  Scenario: Load BRS Transaction

    When I process "${testdata.path}/testdata/${INPUT_FILENAME_BRS}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario: Verify Exception is not raised

    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_STAT_TYP | OPEN |