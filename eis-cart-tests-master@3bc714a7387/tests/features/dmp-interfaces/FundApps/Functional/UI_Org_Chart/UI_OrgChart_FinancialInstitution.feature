@ignore @gs_ui_org_chart @web
#https://jira.intranet.asia/browse/TOM-4870
#There was a requirement change after the creation of template for Org Chart requirement was completed . EDM wants the current template to be modified with the org chart related fields getting added in the existing template.
# Based on the confirmation from EDM , ExportF_ EISFinancialInstitutionForm template would be changed.
#Following fields are added in the template : Under LBU Identifiers Tab Company Number and RCR/LBU Legal Entity ID added , Under SSDR OrgChart Specific Attributes added Regulator , Percent Owned , Under Address Details added Address Line 1 , Address Line 2 ,Country Name

Feature: Test the additional fields added for Org Chart in ExportF_ EISFinancialInstitutionForm template

  Scenario: TC_1: Create New Financial Institution with new fields as below

    Given I login to golden source UI with "task_assignee" role

    When I add Market Details for the MarketGroup as below
      | Institution Name               | DummyInstitution |
      | Parent RCR/LBU Legal Entity ID | DummyParent      |
      | Organisation Type              | Entity           |


    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "DummyInstitution"

    When I relogin to golden source UI with "task_assignee" role

    When I update Financial Institution  "DummyInstitution" with below details
      | Institution Status | Yes=Active |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "DummyInstitution"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Financial Institution  "DummyInstitution"  is updated as below
      | Institution Status | Yes=Active |

  Scenario: Close browsers
    Then I close all opened web browsers
