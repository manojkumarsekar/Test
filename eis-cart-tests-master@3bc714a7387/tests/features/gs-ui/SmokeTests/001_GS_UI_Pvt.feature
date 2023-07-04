@web @pvt @gs_ui_menu_verification @gs_ui_verify_admin_menu @ignore_hooks
Feature: GS Portal Smoke Test - Verify Basic Checks

  The Data Management Platform (DMP) leverages the solutions from vendor Golden Source.
  One of the components of the Golden Source is the Golden Source Portal where users will
  be able to view and manage the data through the Web User Interface.

  This Smoke Test provides some assurance that the deployed application (portal) by
  performing basic tasks on the Web UI to ensure that the basic functionalities are still
  there (after new deployments, changes, or on periodic basis).

  Scenario: Verify GS UI Menu structure
    Given I login to golden source UI with "administrators" role

  Scenario Outline: Verifying Security Master <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu             | SubMenu            |
      | Security Master      | Issue              |
      | Customer Master      | Customer           |
      | Pricing              | Pricing Exceptions |
      | Benchmark Master     | Simple Benchmark   |
      | AuditLog             | Audit Log Report   |
      | Generic Setup        | Geographic Unit    |
      | Exception Management | Load Error Report  |
      | Admin                | Change Label       |
      | DataLineage          | Traceability       |
      | My Worklist          | My Worklist        |

  Scenario: Close browsers
    Then I close all opened web browsers

