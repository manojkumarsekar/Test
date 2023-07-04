@web @gs_ui_regression @gc_ui_account_master
@eisdev_7383 @eisdev_7383_account_master

Feature: Create and Update Account Master with Fundipedia ID details

  This feature file can be used to check the Fundipedia ID details in the account master insert and update functionality over UI.
  This handles both the maker checker event require to update account master.

  Scenario: Create and Update Portfolio/Account Master with Fundipedia ID details

    Given I login to golden source UI with "task_assignee" role

    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I add Portfolio Details for the Account Master as below
      | Portfolio Name          | TST_PORTFOLIO_${VAR_RANDOM} |
      | Portfolio Legal Name    | Test_LegalPortfolio         |
      | Inception Date          | T                           |
      | Base Currency           | USD-US Dollar               |
      | Processed/Non Processed | NON-PROCESSED               |


    When I add Legacy Identifiers details for the Account Master as below
      | CRTS Portfolio Code | CRTS_${VAR_RANDOM} |

    When  I add LBU Identifiers details for the Account Master as below
      | TSTAR Portfolio Code    | TSTAR_${VAR_RANDOM} |
      | Korea MD Portfolio Code | TMD_${VAR_RANDOM}   |

    When I add XReference details for the Account Master as below
      | IRP Code                | IRP_${VAR_RANDOM}     |
      | Fundipedia Fund ID      | FFUNDID_${VAR_RANDOM} |
      | Fundipedia Portfolio ID | FPORTID_${VAR_RANDOM} |

    When I add the parties details in account master with following details
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_PORTFOLIO_${VAR_RANDOM}" is created

    Scenario: Update Portfolio/Account Master with Fundipedia ID details

    Given I login to golden source UI with "task_assignee" role
    And I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    When I update XReferenceIdentifiers in account master with below details
      | Fundipedia Fund ID      | FFUNDID_${VAR_RANDOM}_1 |
      | Fundipedia Portfolio ID | FPORTID_${VAR_RANDOM}_1 |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    And I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    Then I expect Xref details in Account Master is updated as below
      | Fundipedia Fund ID      | FFUNDID_${VAR_RANDOM}_1 |
      | Fundipedia Portfolio ID | FPORTID_${VAR_RANDOM}_1 |
