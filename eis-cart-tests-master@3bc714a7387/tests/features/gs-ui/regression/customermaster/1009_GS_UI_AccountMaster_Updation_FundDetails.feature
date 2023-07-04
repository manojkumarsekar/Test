#https://jira.intranet.asia/browse/TOM-3254
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=24943456
#https://jira.pruconnect.net/browse/EISDEV-5559 - Updating Validation message to match GC Upgrade environment
# eisdev_7202 - Account master enhancements for breaking the BDD

@tom_3254 @web @gs_ui_regression @gc_ui_account_master @eisdev_7202 @eisdev_7180
Feature: Create and Update Account Master

  Currently the "Fund Code" in the GAA Drifted Benchmark Interface file is being sourced from the identifier "CRTS Code" in Golden Source application.
  However BNP requires a fund code with "_M" at the end for all merged portfolios for Performance & Attribution reporting purpose which is currently unavailable in CRTS code.

  This feature file is to test the update of new fields "IRP Code" and "Fund Region" of Account in UI using maker checker event.

  Scenario: TC_1: Create and then Update Portfolio/Account Master new fields

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"

    When I add Portfolio Details for the Account Master as below
      | Portfolio Name          | 3254_PORTFOLIO_${VAR_RANDOM}  |
      | Portfolio Legal Name    | 3254_PORTFOLIO_${VAR_RANDOM} |
      | Inception Date          | T                            |
      | Base Currency           | USD-US Dollar                |
      | Processed/Non Processed | NON-PROCESSED                |

    When I add Fund Details for the Account Master as below
      | Fund Region                 | NONLATAM                                   |

    When I add Legacy Identifiers details for the Account Master as below
      | CRTS Portfolio Code | 3254_${VAR_RANDOM}_CRTS |

    When  I add LBU Identifiers details for the Account Master as below
      | TSTAR Portfolio Code    | 3254_${VAR_RANDOM}_TSTAR   |
      | Korea MD Portfolio Code | 3254_${VAR_RANDOM}_KOREA  |


    When I add XReference details for the Account Master as below
      | IRP Code | 3254_${VAR_RANDOM}_IRP   |

    When I add the parties details in account master with following details
      | Investment Manager                 | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location        | SG-Singapore                               |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role

    And I approve a record from My WorkList with entity name "3254_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "3254_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    And I update XReferenceIdentifiers in account master with below details
      | IRP Code | 3254_${VAR_RANDOM}_IRPNEW |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3254_PORTFOLIO_${VAR_RANDOM}"


    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "3254_PORTFOLIO_${VAR_RANDOM}" is created

    Then I expect Xref details in Account Master is updated as below
      | IRP Code | 3254_${VAR_RANDOM}_IRPNEW |

    Then I close GS tab "GlobalSearch"

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Update IRP Code field with blank and verify mandatory error

    Given I login to golden source UI with "task_assignee" role

    Given I open account master "3254_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    And I update XReferenceIdentifiers in account master with below details
      | IRP Code | null |

    And I save changes

    Then I expect there is 1 validation error on screen
    And I expect below validation error messages on screen
      | GSO / Field        | IRP Code                                                                                                                      |
      | Severity           | ERROR                                                                                                                         |
      | Validation Message | Attribute required for entity completeness * - Mandatory Attributes ; ** - Conditional Mandatory Attributes missing: IRP Code |

    Then I close GS tab "GlobalSearch"

