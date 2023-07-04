#https://jira.pruconnect.net/browse/EISDEV-5282
@web @gs_ui_regression @eisdev_5282 @gc_ui_taiwan_broker_setup @gc_ui_worklist
Feature: Create new Taiwan Broker setup

  This feature file tests the below scenarios:
  1. Create the Broker with ID_CTXT_TYP AS "BRSTRDCNTCDE" in FT_T_FIID and clear the old data in CCRF table as prerequisite
  2. Create the Taiwan Broker setup for ISIN and Portfolio with maker and checker event
  3. Create the same combination again and system should not save and display the error message from UI screen

  Scenario: TC1: Create BRSTRDCNTCDE and clear CCRF as prerequisites

    Given I assign "tests/test-data/gs-ui/regression/taiwanbrokersetup" to variable "testdata.path"
    And I assign "LU0346390270" to variable "ISIN_VAR"
    And I assign "ESP1346912" to variable "PORTFOLIO_CODE"
    And I assign "FIL Securities Investment Trust Co." to variable "TAIWAN_BROKER"
    And I assign "TT140" to variable "ID"

    When I execute below query and extract values of "INSTR_NAME" into same variables
    """
    select ISSU.PREF_ISS_NME AS INSTR_NAME from FT_T_ISSU ISSU
    join FT_T_ISID ISID
    on ISSU.INSTR_ID = ISID.INSTR_ID
    where ISID.ISS_ID='${ISIN_VAR}'
    """

    And I execute below query to "Clear the CCRF,Instrument and portfolio data"
    """
    ${testdata.path}/sql/001_GS_UI_TaiwanBrokerSetup_Prerequisite.sql
    """

    And I execute below query to "Create Broker with ID_CTXT_TYP BRSTRDCNTCDE in FT_T_FIID"
    """
    ${testdata.path}/sql/001_GS_UI_TaiwanBrokerSetup_Insert_BRSTRDCNTCDE_Prerequisite.sql
    """

  Scenario: TC2: Create New Taiwan Broker Setup

    Given I login to golden source UI with "task_assignee" role

    When I create a new Taiwan Broker with below details
      | Portfolio Name         | ${PORTFOLIO_CODE} |
      | ISIN                   | ${ISIN_VAR}       |
      | Taiwan BRS Broker Code | ${TAIWAN_BROKER}  |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${INSTR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INSTR_NAME}"

  Scenario: TC3: Error thrown when creating a duplicate Taiwan Broker Setup

    Given I relogin to golden source UI with "task_assignee" role

    When I create a new Taiwan Broker with below details
      | Portfolio Name         | ${PORTFOLIO_CODE} |
      | ISIN                   | ${ISIN_VAR}       |
      | Taiwan BRS Broker Code | ${TAIWAN_BROKER}  |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${INSTR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I expect a record in My WorkList with entity name "${INSTR_NAME}"
    And I click on authorize record from My WorkList with entity name "${INSTR_NAME}"
    Then I expect error message "Sorry, But Error Message Issued." on popup

  Scenario: TC4: Restore data to original state

    And I execute below query to "Restore updated data to original state"
    """
    ${testdata.path}/sql/001_GS_UI_TaiwanBrokerSetup_ResetDataToOriginalState.sql
    """


