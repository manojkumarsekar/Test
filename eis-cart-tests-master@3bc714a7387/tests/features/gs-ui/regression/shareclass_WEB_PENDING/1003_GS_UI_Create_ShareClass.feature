@ignore @gc_ui_account_master @gc_ui_worklist

Feature: Create ShareClass
  This feature file can be used to check the shareclass create functionality over UI.
  This handles both the maker checker event require to create shareclass.

  Scenario: Create New Portfolio/Account Master

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

  #Click on Account Master link and select EISShareCsass

    When I create account master with following details
      | Portfolio Name     | TST_SHARECLASS_${VAR_RANDOM}                                                      |
      | Inception Date     | T                                                                                 |
      | Base Currency      | USD-US Dollar                                                                     |
      | Active Flag        | Active                                                                            |
      | Share Class Type   | EG                                                                                |
      | RDM Portfolio Code | RDM_${VAR_RANDOM}                                                                 |
      | Primary Benchmark  | Bloomberg Barclays Credit Most Conservative 2% Issuer Cap Bond Index (GBP Hedged) |


    And I save changes

    Then I expect a record in My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_SHARECLASS_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_SHARECLASS_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers
