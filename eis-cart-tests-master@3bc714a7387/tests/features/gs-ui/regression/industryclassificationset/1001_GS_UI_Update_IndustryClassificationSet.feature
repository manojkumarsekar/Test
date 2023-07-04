# https://jira.intranet.asia/browse/TOM-4780: Adding saveDetails and closeTab steps for Industry Classification

@web @gs_ui_regression @gc_ui_industry_classification @gc_ui_worklist

Feature: Update  Industry Classification Set
  This feature file can be used to check the Industry Classification Set update functionality over UI.
  This handles both the maker checker event require to update Industry Classification Set.

  Scenario: Update  Industry Classification Set
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"
    When I add Industry Classification Details for Classification set "MSCHI" with following details
      | Class Name                     | Test_ICS_ClassName               |
      | Class Description              | Test_ICS_ClassDesc_${VAR_RANDOM} |
      | Classification Value           | Test_ICS_Value_${VAR_RANDOM}     |
      | Level Number                   | 123                              |
      | Classification Created On      | T                                |
      | Classification Effective Until |                                  |

    And I save the valid data
    And I close active GS tab
    Then I expect a record in My WorkList with entity id "MSCHI" and status "Open"

    And I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "MSCHI"

    And I relogin to golden source UI with "task_assignee" role
    Then I expect Industry Classification Details for set "MSCHI" are updated as below
      | Class Name        | Test_ICS_ClassName               |
      | Class Description | Test_ICS_ClassDesc_${VAR_RANDOM} |

    And I close active GS tab

  Scenario: Close browsers
    Then I close all opened web browsers
