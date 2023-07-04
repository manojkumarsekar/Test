@ignore @gs_ui_geounit_group @web
#https://jira.pruconnect.net/browse/EISDEV-5242
#For development of Fundapps XML TotalVotingRights and TotalVotingShares based on ExchangeCountryCode

Feature: Test the screen for Geographic Unit Group

  Scenario: TC_1: Create New Geographic Unit Group with new fields as below

    Given I login to golden source UI with "task_assignee" role

    When I add Geographic Unit Group Details Screen for the GeographicUnitGroup as below
      | Group Name               | DummyGroup |
      | Group Purpose   | Reporting      |

    When I add Participant Screen for the Participant as below
      |Geographic Group Participant Purpose              | Reporting |
      | Geographic Participant Unit Type   | COUNTRY      |
      | Geographic Participant Unit ID   | AU      |


    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "DummyGroup"

  Scenario: Close browsers
    Then I close all opened web browsers
