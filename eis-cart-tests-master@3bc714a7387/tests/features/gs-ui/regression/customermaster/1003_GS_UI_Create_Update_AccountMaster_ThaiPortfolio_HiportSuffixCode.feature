@web @gs_ui_regression @eisdev_6721 @eisdev_6721_web @eisdev_6840
@gc_ui_account_master @eisdev_7180

 #eisdev_6840 - Thailand portfolio code added with Thailand Hiport Suffix code in single feature for validation
 # eisdev_7180 - Account master enhancements for breaking the BDD

Feature: Create or Update Account Master with Thailand portfolio code and Thailand Hiport Suffix code

  This feature file can be used to check the Thailand portfolio code in the account master insert and update functionality over UI.
  This feature file can be used to check the Thailand Hiport Suffix code in the account master insert and update functionality over UI.
  This handles both the maker checker event require to update account master.

  Scenario: Update Portfolio/Account Master with Thailand portfolio code and Thailand Hiport Suffix code

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
      | TSTAR Portfolio Code    | TSTAR_${VAR_RANDOM}                  |
      | Korea MD Portfolio Code | TMD_${VAR_RANDOM}                    |
      | Thailand Portfolio Code | THAICODE_INSERT_SCREEN_${VAR_RANDOM} |
      | HIPORT Suffix Code      | SUFFIXCD_INSERT_SCREEN_${VAR_RANDOM} |


    When I add XReference details for the Account Master as below
      | IRP Code | IRP_${VAR_RANDOM} |

    When I add the parties details in account master with following details
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |


    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    When I update LBU in account master with below details
      | Thailand Portfolio Code | THAICODE_UPDATE_SCREEN_${VAR_RANDOM} |
      | HIPORT Suffix Code      | SUFFIXCD_UPDATE_SCREEN_${VAR_RANDOM} |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_PORTFOLIO_${VAR_RANDOM}" is created

    Then I expect LBU details in Account Master is updated as below
      | HIPORT Suffix Code      | SUFFIXCD_UPDATE_SCREEN_${VAR_RANDOM} |
      | Thailand Portfolio Code | THAICODE_UPDATE_SCREEN_${VAR_RANDOM} |

