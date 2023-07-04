@ignore @gc_ui_account_master
Feature: Update ShareClass

  This feature file can be used to check the account master update functionality over UI.
  This handles both the maker checker event require to update account master.

  Scenario: Update Portfolio/Account Master

    Given I login to golden source UI with "task_assignee" role

    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

   # Click on Account Master link and select EISShareCsass

    When I create account master with following details
      | Portfolio Name     | TST_SHARECLASS_${VAR_RANDOM}                                                      |
      | Inception Date     | T                                                                                 |
      | Base Currency      | USD-US Dollar                                                                     |
      | Active Flag        | Active                                                                            |
      | Share Class Type   | EG                                                                                |
      | RDM Portfolio Code | RDM_${VAR_RANDOM}                                                                 |
      | Primary Benchmark  | Bloomberg Barclays Credit Most Conservative 2% Issuer Cap Bond Index (GBP Hedged) |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    And I update account master details for portfolio "TST_SHARECLASS_${VAR_RANDOM}" with below details
      | Base Currency | JPY-Japanese Yen |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_SHARECLASS_${VAR_RANDOM}" is updated as below
      | Base Currency | JPY-Japanese Yen |

  Scenario: Close browsers
    Then I close all opened web browsers
