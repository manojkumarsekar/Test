#https://jira.intranet.asia/browse/TOM-3883

@web @gs_ui_financial_market @tom_3883
Feature: Update Financial Market
  This feature file can be used to check the Financial Market update functionality over UI.
  This handles both the maker checker event require to update Financial Market.

  Scenario: Update Financial Market

    Given I login to golden source UI with "task_assignee" role

    And I update Security Master::Financial Market "MTS ASSOCIATED MARKETS" with following details
      | Market Description | MTS ASSOCIATED MARKETS Desription |

    And I save changes

    Then I expect a record in My WorkList with entity name "MTS ASSOCIATED MARKETS"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "MTS ASSOCIATED MARKETS"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect the Instrument Group "MTS ASSOCIATED MARKETS" is updated as below
      | Market Description | MTS ASSOCIATED MARKETS Desription |

  Scenario: Close browsers
    Then I close all opened web browsers
