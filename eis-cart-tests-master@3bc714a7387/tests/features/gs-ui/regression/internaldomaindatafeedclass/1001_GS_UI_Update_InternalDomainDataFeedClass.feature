@web @gs_ui_regression @tom_3805 @gc_ui_internaldomain_datafeed_class @gc_ui_worklist @eisdev_7481
Feature: Update Internal Domain For Data Feed Class

  This feature file can be used to check the Internal Domian For Data Feed Class update functionality over UI.
  This handles both the maker checker event require to update Internal Domian For Data Feed Class.

  Scenario: Update Internal Domian For Data Feed Class

    Given I execute below query to "Delete any entity in Pending Approval state"

    """
    DELETE FROM FT_WF_UIWA
    WHERE MAIN_ENTITY_ID = 'ADRTX256'
    AND USER_INSTRUC_TXT IS NULL;
    COMMIT;
    """

    And I login to golden source UI with "task_assignee" role

    When I add Domain Values for Internal Domain for Data Feed Class "ADRTX256" with following details
      | Int Domain Value Name        | Test_INTDOMAIN_NAME         |
      | Modification Restriction Ind | Regulatory Value            |
      | Qualified Field ID           | Test_123                    |
      | Domain Set ID                | Test_DOMAINSETID_123        |
      | Column Name                  | Test_COLUMN_NAME            |
      | Data Source ID               | AGEFI                       |
      | Int Domain Value             | Test_INTDOMAIN_VAL          |
      | Int Domain Value Description | Test_INTDOMAIN_DESC         |
      | Qualification Value          | Test_QUALIFICATION_VAL      |
      | Table ID                     | AACO                        |
      | Domain Value Purpose Type    | Instrument Level Identifier |
      | Data Status                  | Active                      |
    Then I expect Internal Domain for Data Feed Class Record is moved to My WorkList for approval

    When I relogin to golden source UI with "task_authorizer" role
    And I approve Internal Domain for Data Feed Class record

    When I relogin to golden source UI with "task_assignee" role
    Then I expect the Internal Domian For Data Feed Class is updated as below
      | Column Name                  | Test_COLUMN_NAME |
      | Modification Restriction Ind | Regulatory Value |

  Scenario: Close browsers
    Then I close all opened web browsers
