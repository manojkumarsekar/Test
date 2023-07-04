#https://jira.intranet.asia/browse/TOM-3493
#https://jira.intranet.asia/browse/TOM-2771

@gc_interface_cash
@dmp_regression_unittest
@tom_3493
Feature: Loading Standard File Load and Expecting no exceptions

  This fix is for the error occurred in production.

  Scenario: TC_1: Load BRS Cash File11 and expect there should not any errors

    Given I assign "esi_itap_non-asia.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3493" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
	  WHERE CHAR_VAL_TXT LIKE '%Multiple Rows Found for FT_T_ETID having key fields : Executed Transaction Identifier=%'
	  AND NOTFCN_STAT_TYP = 'OPEN'
      AND SOURCE_ID = 'GS_GC@ESGSRD'
      AND MSG_TYP='EIS_MT_BRS_CASHALLOC_FILE11'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """





