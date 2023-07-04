Feature: Golden Source Portal Web UI Smoke Test

  Scenario: Open GS web user interface menu

    Given I open a web session from URL "http://vsgeisldapp07.pru.intranet.asia:8780/GS"
    When I enter text "test1" into web element with id "j_username"
    And I enter text "test1@123" into web element with id "j_password"
    And I submit the form of the web element with id "login"

    Then I select from GS menu "Security Master::Issue"

    Then I select from GS menu "Security Master::Instrument Group"

    Then I select from GS menu "Security Master::Issue Type"

    Then I select from GS menu "Security Master::Issue Type Group"

    Then I close all opened web browsers
