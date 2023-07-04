@web @gs_ui_regression @eisdev_6000 @eisdev_6000_web @eisdev_6840 @eisdev_7167
@gc_ui_account_master @eisdev_7180

#eisdev_6840 - Added new gherkin line for method segregation and added new ssdr fields for verifications
# eisdev_7180 - Account master enhancements for breaking the BDD

Feature: Create and Update Account Master with SSDR details

  This feature file can be used to check the SSDR details in the account master insert and update functionality over UI.
  This handles both the maker checker event require to update account master.

  Scenario: Update Portfolio/Account Master with SSDR details

    Given I login to golden source UI with "task_assignee" role

    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I add Portfolio Details for the Account Master as below
      | Portfolio Name              | TST_PORTFOLIO_${VAR_RANDOM}                |
      | Portfolio Legal Name        | Test_LegalPortfolio                        |
      | Inception Date              | T                                          |
      | Base Currency               | USD-US Dollar                              |
      | Processed/Non Processed     | NON-PROCESSED                              |

    When I add Legacy Identifiers details for the Account Master as below
      | CRTS Portfolio Code | CRTS_${VAR_RANDOM} |

    When  I add LBU Identifiers details for the Account Master as below
      | TSTAR Portfolio Code    | TSTAR_${VAR_RANDOM} |
      | Korea MD Portfolio Code | TMD_${VAR_RANDOM}   |

    When I add XReference details for the Account Master as below
      | IRP Code | IRP_${VAR_RANDOM} |

    When I add Regulatory for the Account Master as below
      | MAS Category | A2-FUNDS UNDER ADVISORY SERVICE |

    When I add the parties details in account master with following details
      | Investment Manager                 | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location        | SG-Singapore                               |

    When I add the ssdr details in account master with following details
      | Pru-Group LE Name                              | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | SID Name                                       | TAKAFULINK SALAM (SID - ISD050553024510)   |
      | QFII CN Flag                                   | Y                                          |
      | STC VN Flag                                    | Y                                          |
      | Investment Discretion LE Investment Discretion | Sole-Sole                                  |
      | Non-Group LE Name                              | PRUDENCE FOUNDATION                        |
      | FINI Taiwan Flag                               | Y                                          |
      | PPMA Flag                                      | Y                                          |
      | SSH Flag                                       | Y                                          |
      | Fund Vehicle Type                              | CORPORATE-Corporate                        |
      | Investment Discretion LE VR Discretion         | Sole-Sole                                  |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    When I update ssdr in account master with below details
      | Thailand Portfolio Code                        | THAICODE_UPDATE_SCREEN_${VAR_RANDOM} |
      | Pru-Group LE Name                              | PRUDENCE FOUNDATION                  |
      | SID Name                                       | TPT EMERGING(SID - OTF010773671201)  |
      | QFII CN Flag                                   | N                                    |
      | STC VN Flag                                    | N                                    |
      | Investment Discretion LE Investment Discretion | Shared-Shared                        |
      | Non-Group LE Name                              | Jackson Finance LLC                  |
      | FINI Taiwan Flag                               | N                                    |
      | PPMA Flag                                      | N                                    |
      | SSH Flag                                       | N                                    |
      | Fund Vehicle Type                              | UNIT TRUST-Unit Trust                |
      | Investment Discretion LE VR Discretion         | Shared-Shared                        |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_PORTFOLIO_${VAR_RANDOM}" is created

    Then I expect ssdr details in Account Master is updated as below
      | Pru-Group LE Name                              | PRUDENCE FOUNDATION                 |
      | SID Name                                       | TPT EMERGING(SID - OTF010773671201) |
      | QFII CN Flag                                   | N                                   |
      | STC VN Flag                                    | N                                   |
      | Investment Discretion LE Investment Discretion | Shared-Shared                       |
      | Non-Group LE Name                              | Jackson Finance LLC                 |
      | FINI Taiwan Flag                               | N                                   |
      | PPMA Flag                                      | N                                   |
      | SSH Flag                                       | N                                   |
      | Fund Vehicle Type                              | UNIT TRUST-Unit Trust               |
      | Investment Discretion LE VR Discretion         | Shared-Shared                       |


