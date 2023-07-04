#https://collaborate.pruconnect.net/display/EISTOMR4/Rule+to+update+AEAR.END_TMS+to+SYSDATE+when+EXAC+is+end_dated#Test-Cd
#https://jira.pruconnect.net/browse/EISDEV-5528

@web @gs_ui_regression @eisdev_5528 @eisdev_5480
@gc_ui_external_account

Feature: 001_External_Account: Delete Active External Account with AEAR records from UI
  As user I should able to delete any existing active external account with and without  AEAR records,
  and active record should be end dated in FT_T_EXAC & FT_T_AEAR tables.

  Scenario: Pre requisite steps to extract active external account with AEAR records
  Get active external account instead of creating a new external account.

    Given I execute below query and extract values of "EXAC_OID" into same variables
    """
    SELECT EXAC_OID FROM (
      SELECT  EXAC_OID,COUNT(*) FROM FT_T_AEAR
      WHERE END_TMS IS NULL
      AND LAST_CHG_USR_ID='EIS_RDM_DMP_PORTFOLIO_MASTER'
      GROUP BY EXAC_OID HAVING COUNT(*) > 1
      ORDER BY EXAC_OID ASC)
    WHERE ROWNUM=1
    """

    And I execute below query and extract values of "EXTERNAL_ACCT_ID" into same variables
    """
      SELECT EXTERNAL_ACCT_ID FROM FT_T_EXAC
      WHERE EXAC_OID='${EXAC_OID}' AND END_TMS IS NULL
    """

  Scenario: Delete Active external account  with AEAR records from UI
  Verify external account deleted successfully and end_tms updated as sysdate in DB

    Given I login to golden source UI with "administrators" role
    And I open External Account "${EXTERNAL_ACCT_ID}"
    When I delete from details screen

    # Verifying LAST_CHG_USR_ID is updated as 'testadministrator' and end_ths as sysdate in FT_T_EXAC table
    Then I expect value of column "EXAC_CNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXAC_CNT FROM FT_T_EXAC
      WHERE EXAC_OID='${EXAC_OID}'
      AND EXTERNAL_ACCT_ID='${EXTERNAL_ACCT_ID}'
      AND TRUNC(END_TMS)=TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='testadministrator'
    """

    # Verifying LAST_CHG_USR_ID is updated as 'EIS_UPDATEAEARENDTMS_RULEPROCESSOR' and end_ths as sysdate in FT_T_AEAR table
    And I expect value of column "ACTIVE_STATUS" in the below SQL query equals to "PASS":
    """
      SELECT CASE WHEN COUNT(1)>1 THEN 'PASS' ELSE 'FAIL' END AS ACTIVE_STATUS
      FROM FT_T_AEAR
      WHERE EXAC_OID='${EXAC_OID}' 
      AND TRUNC(END_TMS)=TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_UPDATEAEARENDTMS_RULEPROCESSOR'
    """

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: Pre requisite steps to extract active external account without any AEAR records
  Get active external account instead of creating a new external account.

    Given I execute below query and extract values of "EXTERNAL_ACCT_ID" into same variables
    """
      SELECT EXTERNAL_ACCT_ID FROM FT_T_EXAC EXAC
      WHERE NOT EXISTS(
        SELECT 1 FROM FT_T_AEAR
        WHERE END_TMS IS NULL
        AND EXAC.EXAC_OID=EXAC_OID )
      AND END_TMS IS NULL
      AND ROWNUM=1
    """

  Scenario: Delete Active external account without any FT_T_AEAR records from UI
  Verify external account deleted successfully and end_tms updated as sysdate in DB

    Given I login to golden source UI with "administrators" role
    And  I open External Account "${EXTERNAL_ACCT_ID}"

    When I delete from details screen

 # verifying LAST_CHG_USR_ID is updated as 'testadministrator' and end_ths as sysdate in FT_T_EXAC table
    Then I expect value of column "EXAC_CNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXAC_CNT FROM FT_T_EXAC
      WHERE EXTERNAL_ACCT_ID='${EXTERNAL_ACCT_ID}'
      AND TRUNC(END_TMS)=TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='testadministrator'
    """

  Scenario: Close browsers
    Then I close all opened web browsers