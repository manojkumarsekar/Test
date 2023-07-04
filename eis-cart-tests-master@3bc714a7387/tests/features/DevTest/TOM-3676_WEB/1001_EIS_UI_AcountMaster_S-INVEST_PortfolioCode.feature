@tom_3676 @web @ignore @gc_ui_worklist
@gc_ui_account_master

Feature: Create Account Master
  This feature file can be used to check the account master create functionality over UI.
  This handles both the maker checker event require to create account master.

  Scenario: Create New Portfolio/Account Master

    Given I login to golden source UI with "task_assignee" role

    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"

    When I create account master with following details
      | Portfolio Name              | 3676_PF_${VAR_RANDOM}                      |
      | Portfolio Legal Name        | Test_LegalPortfolio                        |
      | Inception Date              | T                                          |
      | Base Currency               | USD-US Dollar                              |
      | Processed/Non Processed     | NON-PROCESSED                              |
      | Fund Category               | LIFE - LIFE                                |
      | CRTS Portfolio Code         | TSTAUT                                     |
      | S-INVEST Portfolio Code     | TSTAUT                                     |
      | IRP Code                    | TSTAUT                                     |
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |
      | MAS Category                | A2-FUNDS UNDER ADVISORY SERVICE            |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3676_PF_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Account Master "3676_PF_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers
