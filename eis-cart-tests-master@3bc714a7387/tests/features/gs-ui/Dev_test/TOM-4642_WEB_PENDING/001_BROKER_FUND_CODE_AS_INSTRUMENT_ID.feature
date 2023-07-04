#https://jira.intranet.asia/browse/TOM-4642

@tom_4642 @gs_ui_regression @ignore
Feature: To setup Broker fund code as Instrument Identifier(FT_T_ISID)
  The feature file is used to setup Broker fund code as Instrument Identifier in the Instrument screen.

  Scenario: Setup Broker fund code

    Given I login to golden source UI with "task_assignee" role

    When I add instrument Identifier with following details
      | Instrument Identifier | HK0274       |
      | ID context type       | BROKERFUNDCD |

    And I save changes

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "Instrument Identifier"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect external account "Instrument Identifier" is created

  Scenario: Closing Browsers
    Then I close all opened web browsers
