@gc_ui_share_class @gc_ui_worklist @gs_ui_regression
@eisdev_7383 @eisdev_7383_shareclass

Feature: Create ShareClass
  This feature file can be used to check the shareclass create functionality over UI.
  This handles both the maker checker event require to create shareclass.

  Scenario: Create New Shareclass

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I create shareclass with following details
      | Portfolio Name                 | TST_SHARECLASS_${VAR_RANDOM}                                                      |
      | Inception Date                 | T                                                                                 |
      | Base Currency                  | USD-US Dollar                                                                     |
      | Share Class Type               | ADM                                                                               |
      | Active Flag                    | Active                                                                            |
      | BNP Portfolio Performance Flag | N                                                                                 |
      | RDM Portfolio Code             | RDM_${VAR_RANDOM}                                                                 |
      | Fundipedia Fund ID             | FFUNDID_${VAR_RANDOM}                                                             |
      | Fundipedia Portfolio ID        | FPORTID_${VAR_RANDOM}                                                             |
      | Fundipedia Share Class ID      | FSHRCLSSID_${VAR_RANDOM}                                                          |
      | Primary Benchmark              | Bloomberg Barclays Credit Most Conservative 2% Issuer Cap Bond Index (GBP Hedged) |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_SHARECLASS_${VAR_RANDOM}" is created

    When I update shareclass XReference Details in shareclass with following details
      | Fundipedia Fund ID        | FFUNDID_${VAR_RANDOM}_1    |
      | Fundipedia Portfolio ID   | FPORTID_${VAR_RANDOM}_1    |
      | Fundipedia Share Class ID | FSHRCLSSID_${VAR_RANDOM}_1 |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    And I open account master "TST_SHARECLASS_${VAR_RANDOM}" for the given portfolio

    Then I expect the shareclass is updated as below
      | Fundipedia Fund ID        | FFUNDID_${VAR_RANDOM}_1    |
      | Fundipedia Portfolio ID   | FPORTID_${VAR_RANDOM}_1    |
      | Fundipedia Share Class ID | FSHRCLSSID_${VAR_RANDOM}_1 |

    And I close all opened web browsers

