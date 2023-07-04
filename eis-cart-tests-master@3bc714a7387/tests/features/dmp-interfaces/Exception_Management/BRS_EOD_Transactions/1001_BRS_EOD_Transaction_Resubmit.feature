#base jira : https://jira.pruconnect.net/browse/EISDEV-6486
#EISDEV-6613: Corrected verification query and updated resubmit exceptions workflow call

@gc_interface_transactions @gc_interface_resubmit_exception
@dmp_regression_integrationtest
@eisdev_6486 @eisdev_6613
Feature: Resubmit Exception for BRS Transaction

  Verify Exception For BRS Transaction not closed when touch count of the exception message and message in db is same while resubmitting msg

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/BRS_EOD_Transactions/inputfiles" to variable "testdata.path"
    And I assign "15923_102_trn.xml" to variable "INPUT_FILENAME_BRS"

    And I execute below query to "Update existing EXTR.TRD_ID to new oid"
	"""
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID() WHERE TRD_ID IN ('15923-102');
    COMMIT
    """

  Scenario: Load BRS Transaction

    When I process "${testdata.path}/testdata/${INPUT_FILENAME_BRS}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}            |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verify Exception is Raised

    Given I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' ) AND NOTFCN_STAT_TYP = 'OPEN'
      """

  Scenario: Resubmit Exception

    Given I assign "${JOB_ID}" to variable "JOB_ID1"
    And I assign "SELECT TRN_ID FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' ) AND NOTFCN_STAT_TYP = 'OPEN'" to variable "SQLQuery"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ResubmitBulkExceptions_GC/request.xmlt" to variable "RESUBMIT_EXCPTN_WF"
    And I process the workflow template file "${RESUBMIT_EXCPTN_WF}" with below parameters and wait for the job to be completed
      | SQLQuery | ${SQLQuery} |

  Scenario: Verify Exception Count

    Given I expect value of column "resubmit_count" in the below SQL query equals to "1":
      """
      select count(*) as resubmit_count from ft_t_ntel where LAST_CHG_TRN_ID in(
      select trn_id from ft_t_trid where ORIG_TRN_ID in (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID1}')) AND NOTFCN_STAT_TYP = 'OPEN' and NOTFCN_OCCUR_CNT = 2
      """