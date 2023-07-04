#https://collaborate.pruconnect.net/display/EISTOMR4/Rule+to+update+AEAR.END_TMS+to+SYSDATE+when+EXAC+is+end_dated#Test-Cd
#https://jira.pruconnect.net/browse/EISDEV-5528

@web @gs_ui_regression @eisdev_5528 @eisdev_5480
@gc_ui_external_account

Feature: 002_External_Account: Update Active External Account with AEAR records from UI
  As user I should able to Update any existing active external account.
  and active record should not be end dated in FT_T_EXAC & FT_T_AEAR tables.

  Scenario: Pre requisite steps to extract active external account
  Get active external account instead of creating a new external account.

    Given I execute below query and extract values of "EXAC_OID" into same variables
    """
      SELECT EXAC_OID FROM (
        SELECT  EXAC_OID,COUNT(*) FROM FT_T_AEAR
        WHERE END_TMS IS NULL
        AND LAST_CHG_USR_ID='EIS_RDM_DMP_PORTFOLIO_MASTER'
        GROUP BY EXAC_OID HAVING COUNT(*) > 1
        ORDER BY EXAC_OID DESC)
      WHERE ROWNUM=1
    """

    And I execute below query and extract values of "EXTERNAL_ACCT_ID" into same variables
    """
      SELECT EXTERNAL_ACCT_ID FROM FT_T_EXAC
      WHERE EXAC_OID='${EXAC_OID}'
      AND END_TMS IS NULL
    """

  Scenario: Update Active external account from UI
  Verify external account updated successfully and end_tms is not end_dated in DB

    Given I login to golden source UI with "administrators" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "Eastspring Test Automation Updated_${VAR_RANDOM}" to variable "NEW_EXT_ACCOUNT_NME"
    And I open External Account "${EXTERNAL_ACCT_ID}"

    When I update below external account details
      | External Account Name | ${NEW_EXT_ACCOUNT_NME} |

    And I save the valid data

#    Verifying new External name (EXT_ACCT_NME) is updated and end_tms is null in FT_T_EXAC table
    Then I expect value of column "EXAC_CNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXAC_CNT FROM FT_T_EXAC
      WHERE EXTERNAL_ACCT_ID='${EXTERNAL_ACCT_ID}'
      AND EXT_ACCT_NME='${NEW_EXT_ACCOUNT_NME}'
      AND END_TMS IS NULL
    """

#    Verifying end_tms is null in FT_T_AEAR table
    And I expect value of column "ACTIVE_STATUS" in the below SQL query equals to "PASS":
    """
      SELECT CASE WHEN COUNT(1)>1 THEN 'PASS' ELSE 'FAIL' END AS ACTIVE_STATUS
      FROM FT_T_AEAR
      WHERE EXAC_OID='${EXAC_OID}'
      AND END_TMS IS NULL
    """

  Scenario: Close browsers
    Then I close all opened web browsers