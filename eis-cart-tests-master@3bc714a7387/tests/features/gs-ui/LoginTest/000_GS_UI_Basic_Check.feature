#This test not required for smoke test
@web @basic_login @ignore_hooks
Feature: Golden Source Portal Web UI Smoke Test

  The Data Management Platform (DMP) leverages the solutions from vendor Golden Source.
  One of the components of the Golden Source is the Golden Source Portal where users will
  be able to view and manage the data through the Web User Interface.

  This Smoke Test provides some assurance that the deployed application (portal) by
  performing basic tasks on the Web UI to ensure that the basic functionalities are still
  there (after new deployments, changes, or on periodic basis).

  Scenario: Login to GS web UI
    
    Given I open a web session from URL "${gs.web.UI.url}"
    When I enter the text "${gs.web.UI.administrators.username}" into web element with id "j_username"
    And I enter the text "${gs.web.UI.administrators.password}" into web element with id "j_password"
    And I take a screenshot
    When I submit the web element "id:login"
    And I pause for 2 seconds
    Then I take a screenshot