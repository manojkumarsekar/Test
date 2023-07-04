#Feature History
#TOM-3768: Created New Feature file to Sanity test "Publishing from UI Wrapper" workflow

#@dmp_smoke @tom_3768 @publishing_from_ui_wf @web
@ignore @web @dmp_smoke
Feature: GC Smoke | Orchestrator | ESI | Publishing | Publishing from UI Wrapper

  Scenario: Click Email

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    Given I login to golden source UI with "administrators" role
    Then I pause for 1 seconds

    When I select from GS menu "Customer Master::Account Master"
    Then I pause for 1 seconds

    Then I search GS table input column "Portfolio Name" with "GMN US MULTI-FACTOR EQUITY SUB-FUND" followed by "ENTER" key
    And I pause for 2 seconds

    Then I click the web element with xpath "//span[text()='E-mail']/ancestor::div[@role='button']"
    And I pause for 2 seconds

    And I logout from Golden Source UI

    And I pause for 30 seconds

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE WORKFLOW_ID IN
        (SELECT WORKFLOW_ID FROM FT_WF_WFDF WHERE WORKFLOW_NME = 'EIS_PublishingFromUIWrapper')
        AND WORKFLOW_START_TMS > TO_DATE('20181220 102405', 'YYYYMMDD HH24MISS')
        """

  Scenario: Close all browsers
    Then I close all opened web browsers

