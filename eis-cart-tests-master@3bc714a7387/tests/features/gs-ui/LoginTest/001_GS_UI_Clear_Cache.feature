@clearcache
Feature: This is to clear cache

  Scenario: Login to GS UI and Clear Cache

    Given I login to golden source UI with "administrators" role
    Then I pause for 2 seconds

    When I click the web element with xpath "//span[contains(@class,'gsUserMenu')]"
    Then I click the web element with xpath "//span[text()='Clear Cache']/.."

    Then I pause for 1 seconds
    And I logout from Golden Source UI

  Scenario: Close all browsers
    Then I close all opened web browsers