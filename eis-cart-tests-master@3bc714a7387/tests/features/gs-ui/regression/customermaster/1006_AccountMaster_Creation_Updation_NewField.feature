#https://jira.intranet.asia/browse/TOM-3792
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+portfolio+and+share+class+requirement#businessRequirements--673930711
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48892955

@tom_3792 @web @gs_ui_regression @gc_ui_account_master
Feature: Create and Update Account Master for newly added fields in the Account master using maker checker event

  As part of Taiwan Business requirement adding the 5 fields in the UI.
  This feature file is to test newly added below fields in the Account master using maker checker event.
  1. Traditional Chinese Long Name
  2. Traditional Chinese Short Name
  3. Taiwan e-sun Special Platform
  4. Taiwan Uniform Business Number
  5. Taiwan SITCA Fund ID

  Scenario: TC_1: Create and then Update Portfolio/Account Master new fields

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"

  #  When I create account master with following details
  #    | Portfolio Name                 | 3792_PORTFOLIO_${VAR_RANDOM}               |
  #    | Portfolio Legal Name           | 3792_PORTFOLIO_${VAR_RANDOM}               |
  #    | Inception Date                 | T                                          |
  #    | Base Currency                  | USD-US Dollar                              |
  #    | Processed/Non Processed        | NON-PROCESSED                              |
  #    | Fund Region                    | NONLATAM                                   |
  #    | Investment Manager             | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
  #    | Investment Manager Location    | SG-Singapore                               |
  #    | CRTS Portfolio Code            | 3792_${VAR_RANDOM}_CRTS                    |
  #    | TSTAR Portfolio Code           | 3792_${VAR_RANDOM}_TSTAR                   |
  #    | Korea MD Portfolio Code        | 3792_${VAR_RANDOM}_KOREA                   |
  #    | IRP Code                       | 3792_${VAR_RANDOM}_IRP                     |
  #    | Traditional Chinese Long Name  | 3792_${VAR_RANDOM}_TRD_LONG_NAME           |
  #    | Traditional Chinese Short Name | 3792_${VAR_RANDOM}_TRD_LONG_NAME           |
  #    | Taiwan e-sun Special Platform  | Yes                                        |
  #    | Taiwan Uniform Business Number | 3792_${VAR_RANDOM}_UNI_BUS_NUM             |
  #    | Taiwan SITCA Fund ID           | 3792_${VAR_RANDOM}_SITCA_FUNDID            |


  #  And I save changes

  #  When I relogin to golden source UI with "task_authorizer" role
  #  And I approve a record from My WorkList with entity name "3792_PORTFOLIO_${VAR_RANDOM}"

  #  When I relogin to golden source UI with "task_assignee" role
  #  Then I expect Account Master "3792_PORTFOLIO_${VAR_RANDOM}" is created

  #  Then I close GS tab "GlobalSearch"

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Update Newly added

    Given I login to golden source UI with "task_assignee" role

  #  And I update account master details for portfolio "3792_PORTFOLIO_${VAR_RANDOM}" with below details
  #    | Traditional Chinese Long Name  | 3792_${VAR_RANDOM}_TRD_LONG_NAME_NEW |
  #    | Traditional Chinese Short Name | 3792_${VAR_RANDOM}_TRD_LONG_NAME_NEW |
  #    | Taiwan e-sun Special Platform  | No                                   |
  #    | Taiwan Uniform Business Number | 3792_${VAR_RANDOM}_UNI_BUS_NUM_NEW   |
  #    | Taiwan SITCA Fund ID           | 3792_${VAR_RANDOM}_SITCA_FUNDID_NEW  |

  #  And I save changes

  #  When I relogin to golden source UI with "task_authorizer" role
  #  And I approve a record from My WorkList with entity name "3792_PORTFOLIO_${VAR_RANDOM}"

  #  Then I expect Account Master "3792_PORTFOLIO_${VAR_RANDOM}" is updated as below
  #    | Traditional Chinese Long Name  | 3792_${VAR_RANDOM}_TRD_LONG_NAME_NEW |
  #    | Traditional Chinese Short Name | 3792_${VAR_RANDOM}_TRD_LONG_NAME_NEW |
  #    | Taiwan e-sun Special Platform  | No                                   |
  #    | Taiwan Uniform Business Number | 3792_${VAR_RANDOM}_UNI_BUS_NUM_NEW   |
  #    | Taiwan SITCA Fund ID           | 3792_${VAR_RANDOM}_SITCA_FUNDID_NEW  |

  #  Then I close GS tab "GlobalSearch"

  Scenario: Close browsers
    Then I close all opened web browsers