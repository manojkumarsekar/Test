#https://jira.intranet.asia/browse/TOM-2539
#https://jira.intranet.asia/browse/TOM-3496

@tom_3496 @web @dmp_securities_linking @1004_eis_ui_bbloanid @gs_ui_regression @ignore
Feature: Setup Instrument for BBLOANID in UI

  This fix is for the error occurred in production.

  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with LX then update ID_CTXT_TYP to ‘MRKTLOANID’
  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with BL then update ID_CTXT_TYP to ‘BBLOANID’

  Scenario: TC_1: Create New Instrument

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"
    When I create a Instrument with following details
      | Instrument Name          | Test_BBLoanID${VAR_RANDOM} |
      | Instrument System Status | Active                     |
      | Instrument Type          | Miscellaneous              |
      | BB Loan ID               | BL${VAR_RANDOM}            |
      | BB Identifier            | AB${VAR_RANDOM}            |
      | LoanX ID                 | LX${VAR_RANDOM}            |

    Then I expect the created "Instrument" is moved to My WorkList for approval
    When I relogin to golden source UI with "task_authorizer" role
    And I expect the created "Instrument" is moved to My WorkList for approval
    And I approve the "Instrument"
    When I relogin to golden source UI with "task_assignee" role
    Then I expect the created "Instrument" is present in search list

  Scenario: TC_2: Verify BBLOANID

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='BL${VAR_RANDOM}'
	  AND ID_CTXT_TYP ='BBLOANID'
	  AND END_TMS IS NULL
      """

  Scenario: TC_3: Verify LOANXID

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='LX${VAR_RANDOM}'
	  AND ID_CTXT_TYP ='LOANXID'
	  AND END_TMS IS NULL
      """