@web @gs_ui_regression @gc_ui_institution @gc_ui_worklist

Feature: Create New Institution
  This feature file can be used to check the Institution create functionality over UI.
  This handles both the maker checker event require to create Institution.

  Scenario: Create New Institution

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I add new Institution with following details
      | Institution Name             | Test_Institution1_${VAR_RANDOM} |
      | Institution Description      | Test_Institution_DESC           |
      | Preferred Identifier Name    | AGENT                           |
      | Preferred Identifier Value   | Test_Identifier_VALUE           |
      | Country Of Incorporation     | United States (the)             |
      | Country Of Domicile          | Albania                         |
      | Institution Status           | Active                          |
      | Institution Status Date/Time | T                               |

    And I add Institution Identifiers with following details
      | Inhouse Identifier | ESIIDENT_${VAR_RANDOM}    |
      | BRS Issuer ID      | BRSISSUEID_${VAR_RANDOM}  |
      | HIP Broker ID      | HIPBROKERID_${VAR_RANDOM} |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "Test_Institution1_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "Test_Institution1_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Institution "Test_Institution1_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers
