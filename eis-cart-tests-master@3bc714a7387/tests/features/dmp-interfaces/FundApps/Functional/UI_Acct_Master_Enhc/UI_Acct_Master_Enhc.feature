@ignore @gs_acct_master @web
#https://jira.intranet.asia/browse/TOM-4871
#The current Account Master UI has been enhanced to include fields added from SSDR (FundApps project) perspective
# ExportF- FormAccountMasterDetails has been enhanced
#Following fields are added in the template : Under the section Parties (existing) - Investment Advisor Level 3 LE Name and Investment Advisor Level 4 LE Name added
#Following fields are added in the template : SSDR Details (New Section) - Pru Group LE Name , Non-Group LE Name, SID Name , Investment Discretion LE Investment Discretion , Investment Discretion LE VR Discretion
#Fund Vehicle Type ,FINI Taiwan Flag,MNG Flag  , PPMA Flag ,QFII CN Flag , SSH Flag and STC VN Flag


Feature: Test the additional fields added for Org Chart in ExportF- FormAccountMasterDetails template

  Scenario: Create New Portfolio/Account Master

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I create account master with following details
      | Portfolio Name              | TST_PORTFOLIO_${VAR_RANDOM}                |
      | Portfolio Legal Name        | Test_LegalPortfolio                        |
      | Inception Date              | T                                          |
      | Base Currency               | USD-US Dollar                              |
      | Processed/Non Processed     | NON-PROCESSED                              |
      | Fund Category               | LIFE - LIFE                                |
      | CRTS Portfolio Code         | CRTS_${VAR_RANDOM}                         |
      | TSTAR Portfolio Code        | TSTAR_${VAR_RANDOM}                        |
      | Korea MD Portfolio Code     | TMD_${VAR_RANDOM}                          |
      | IRP Code                    | IRP_${VAR_RANDOM}                          |
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |
      | MAS Category                | A2-FUNDS UNDER ADVISORY SERVICE            |
      | SSH Flag                    |Y                                           |
      | Fund Vehicle Type           | CORPORATE-Corporate                        |



    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    When I update Account Master "TST_PORTFOLIO_${VAR_RANDOM}" with below details
      | MNG Flag  | Y |
      | PPMA Flag | Y |


    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Financial Institution  "DummyInstitution"  is updated as below
      | MNG Flag  | Y |
      | PPMA Flag | Y |

  Scenario: Close browsers
    Then I close all opened web browsers
