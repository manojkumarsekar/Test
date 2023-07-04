@web @gs_ui_regression @tom_3805 @gc_ui_internaldomain_datafeed @gc_ui_worklist @eisdev_7481
Feature: Update Internal Domian For Data Feed

  This feature file can be used to check the Internal Domian For Data Feed update functionality over UI.
  This handles both the maker checker event require to update Internal Domian For Data Feed.

  Scenario: Update Internal Domian For Data Feed Class
    Given I execute below query to "Delete any entity in Pending Approval state"

    """
    DELETE FROM FT_WF_UIWA
    WHERE MAIN_ENTITY_ID = '00000010'
    AND USER_INSTRUC_TXT IS NULL;
    COMMIT;
    """

    And I login to golden source UI with "task_assignee" role
    When I add Domain Values for Internal Domain for Data Feed "00000010" with following details
      | Int Domain Value Name        | Test_INTDOMAIN_NAME         |
      | Modification Restriction Ind | Regulatory Value            |
      | Qualified Field ID           | Test_123                    |
      | Table ID                     | AABP                        |
      | Domain Set ID                | Test_DOMAINSETID_123        |
      | Data Stream ID               | Test_123                    |
      | Int Domain Value             | TST_INTDOMAIN_VAL           |
      | Int Domain Value Description | TST_INTDOMAIN_DESC          |
      | Qualification Value          | TST_QUALI_VAL               |
      | Column Name                  | TST_COLUMN_NAME             |
      | Domain Value Purpose Type    | Instrument Level Identifier |
      | Field Data Class ID          |                             |

    Then I expect Internal Domain for Data Feed Record is moved to My WorkList for approval

    When I relogin to golden source UI with "task_authorizer" role
    And I approve Internal Domain for Data Feed record

    When I relogin to golden source UI with "task_assignee" role
    Then I expect the Internal Domian For Data Feed is updated as below
      | Table ID                     | AABP             |
      | Modification Restriction Ind | Regulatory Value |

  Scenario: Close browsers
    Then I close all opened web browsers
