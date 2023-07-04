#https://jira.intranet.asia/browse/TOM-3354
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498

@web @tom_3354 @gs_ui_smoke @dmp_account_group
Feature: Create Account group
  This feature file can be used to check the if Cross reference created for the Account group over UI.

  Scenario: TC_1: Create Account group

    Given I login to golden source UI with "administrators" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a new Account Group with below details
      | Group ID          | RIO_${VAR_RANDOM}     |
      | Group Name        | RIO_GRP_${VAR_RANDOM} |
      | Group Purpose     | Universe              |
      | Group Description | 3354_TestAccntGrp     |

    And I save changes

    Then I expect value of column "CCRF_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS CCRF_COUNT FROM FT_T_CCRF
      WHERE TRUNC(START_TMS) = TRUNC(SYSDATE)
      AND END_TMS IS NULL
      AND ACCT_GRP_OID =
        (
          SELECT ACCT_GRP_OID FROM FT_T_ACGR
          WHERE ACCT_GRP_ID = 'RIO_${VAR_RANDOM}'
          AND GRP_NME = 'RIO_GRP_${VAR_RANDOM}'
          AND TRUNC(START_TMS) = TRUNC(SYSDATE)
          AND END_TMS IS NULL
        )
      """

  Scenario: Close browsers
    Then I close all opened web browsers
