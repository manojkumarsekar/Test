#As part of EISDEV-6907, Look up on Instrument Group screen has changed from Instrument Name to Preferred Identifier Value

@web @gs_ui_regression @eisdev_7007 @eisdev_7369
@gc_ui_instrument_group

Feature: Update Instrument Group
  This feature file can be used to check the Instrument Group update functionality over UI.
  This handles both the maker checker event require to update Instruument Group.

  Scenario: Update Instrument Group
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I create Instrument Group with following details
      | Group ID               | TST_GRPID_${VAR_RANDOM}   |
      | Group Name             | TST_INS_GRP_${VAR_RANDOM} |
      | Group Purpose          | Account Download          |
      | Group Description      | TST_GROUPDESC             |
      | Subscriber/Down Stream | BNP_CASHALLOC_ITAP        |
      | Enterprise             | EIS                       |
      | Asset Subdivision Name |                           |
      | Group Created On       | T                         |
      | Group Effective Until  |                           |

    When I add Instrument Group Participant with following details
      | Participant Purpose         | Acceleration Clause   |
      | Participant Description     | Test_Participant_DESC |
      | Participant Amount          | 500                   |
      | Participant Percent         | 5                     |
      | Participant Currency        | 10  - Old Krona (old) |
      | Participation Type          | Amount                |
      | Participant Created On      | T                     |
      | Participant Effective Until |                       |


    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_INS_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_INS_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    And I update Instrument group "TST_INS_GRP_${VAR_RANDOM}" with following details
      | Group Purpose     | Administration |
      | Group Description | TST_GROUPDESC  |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_INS_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_INS_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect the Instrument Group "TST_INS_GRP_${VAR_RANDOM}" is updated as below
      | Group Purpose     | Administration |
      | Group Description | TST_GROUPDESC  |

  Scenario: Close browsers
    Then I close all opened web browsers
