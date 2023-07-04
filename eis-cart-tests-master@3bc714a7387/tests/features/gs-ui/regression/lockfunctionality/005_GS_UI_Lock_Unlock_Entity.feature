#https://jira.pruconnect.net/browse/EISDEV-6313
#EISDEV-7458 : Disable drools for MainEntityID and MainEntityIdCtxtTyp and move to java rule to suppress additional changes shown for those 2 fields on UI

@web @gs_ui_regression @gs_ui_lock_entity @eisdev_6313 @eisdev_6365 @eisdev_6820
@gc_ui_lock @eisdev_7458

Feature: Lock an entity and unlock the entity
  This feature file can be used to check the below scenarios
  1. Locking an entity
  2. Unlocking the entity

  Scenario: TC1: Assign variables and create portfolio as prerequisite

    Given I assign "Portfolio Name" to variable "FIELD_NAME"

    And I execute below query and extract values of "PORTFOLIO_CODE" into same variables
    """
    WITH ACCT_ID_CTE AS
      (SELECT STAT_CHAR_VAL_TXT,
       ROW_NUMBER()OVER (ORDER BY LAST_CHG_TMS DESC) AS ROWNUMBER
       FROM FT_T_ACST
       WHERE STAT_DEF_ID = 'ATENID'
       AND END_TMS IS NULL
       AND TRUNC(START_TMS)!=TRUNC(SYSDATE)
       AND ACCT_ID NOT IN
       (SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID IN (SELECT MAIN_ENTITY_ID FROM FT_WF_UIWA WHERE USER_INSTRUC_TXT IS NULL)))
    SELECT  STAT_CHAR_VAL_TXT AS PORTFOLIO_CODE
    FROM ACCT_ID_CTE
    WHERE ROWNUMBER=5
    """

  Scenario: TC2: Lock an existing portfolio

    Given I login to golden source UI with "task_assignee" role

    When I open "Account:${PORTFOLIO_CODE}" from global search
    And I lock an entity
    And I save the valid data

    Then I expect a record in My WorkList with entity id "${PORTFOLIO_CODE}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "${PORTFOLIO_CODE}"

    And I relogin to golden source UI with "task_assignee" role
    And I open "Account:${PORTFOLIO_CODE}" from global search

    Then I should see the entity "${PORTFOLIO_CODE}" is "locked"

  Scenario: TC2: Unlock the entity

    Given I login to golden source UI with "task_assignee" role

    When I open "Account:${PORTFOLIO_CODE}" from global search
    And I unlock an entity
    And I save the valid data

    Then I expect a record in My WorkList with entity id "${PORTFOLIO_CODE}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "${PORTFOLIO_CODE}"

    And I relogin to golden source UI with "task_assignee" role
    And I open "Account:${PORTFOLIO_CODE}" from global search

    Then I should see the entity "${PORTFOLIO_CODE}" is "unlocked"