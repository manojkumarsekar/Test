#https://jira.intranet.asia/browse/TOM-3792
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+portfolio+and+share+class+requirement#businessRequirements--673930711
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48892955

@tom_3792 @web @gs_ui_regression @gc_ui_account_master
Feature: Create and Update Shareclass Account Master

  As part of Taiwan Business requirement adding the 5 fields in the UI.
  This feature file is to test newly added below fields in the Shareclass Account master using maker checker event.
  1. Traditional Chinese Long Name
  2. Traditional Chinese Short Name
  3. Hedge Portfolio Name
  4. Taiwan Uniform Business Number
  5. Taiwan SITCA Fund ID

  Scenario: TC_1: Create and then Update Shareclass Portfolio/Account Master new fields

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"

  #  When I create account master with following details
  #    | Portfolio Name                 | 3792_SHARECLASS_PORTFOLIO_${VAR_RANDOM}    |
  #    | Base Currency                  | USD-US Dollar                              |
  #    | Inception Date                 | T                                          |
  #    | Share Class Type               | BS                                         |
  #    | Traditional Chinese Long Name  | 3792_${VAR_RANDOM}_SHARE_TRD_LONG_NAME     |
  #    | Traditional Chinese Short Name | 3792_${VAR_RANDOM}_SHARE_TRD_LONG_NAME     |
  #    | Hedge Portfolio Name           | GMN US MULTI-FACTOR EQUITY SUB-FUND        |
  #    | RDM Portfolio Code             | 3792_${VAR_RANDOM}_RDM                     |
  #    | Primary Benchmark              | Malayan Banking Berhad 12 Month FD rate MYR|
  #    | Taiwan Uniform Business Number | 3792_${VAR_RANDOM}_UNI_BUS_NUM             |
  #    | Taiwan SITCA Fund ID           | 3792_${VAR_RANDOM}_SITCA_FUNDID            |


  #  And I save changes

  #  When I relogin to golden source UI with "task_authorizer" role
  #  And I approve a record from My WorkList with entity name "3792_SHARECLASS_PORTFOLIO_${VAR_RANDOM}"

  #  When I relogin to golden source UI with "task_assignee" role
  #  Then I expect Shareclass Account Master "3792_SHARECLASS_PORTFOLIO_${VAR_RANDOM}" is created

  #  Then I close GS tab "GlobalSearch"

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Update Newly added

    Given I login to golden source UI with "task_assignee" role

  #  And I update Shareclass account master details for portfolio "3792_SHARECLASS_PORTFOLIO_${VAR_RANDOM}" with below details
  #    | Traditional Chinese Long Name  | 3792_${VAR_RANDOM}_SHARE_TRD_LONG_NAME_NEW     |
  #    | Traditional Chinese Short Name | 3792_${VAR_RANDOM}_SHARE_TRD_LONG_NAME_NEW     |
  #    | Hedge Portfolio Name           | MFAW0001                                       |
  #    | Taiwan Uniform Business Number | 3792_${VAR_RANDOM}_UNI_BUS_NUM_NEW             |
  #    | Taiwan SITCA Fund ID           | 3792_${VAR_RANDOM}_SITCA_FUNDID_NEW            |

  #  And I save changes

  #  When I relogin to golden source UI with "task_authorizer" role
  #  And I approve a record from My WorkList with entity name "3792_SHARECLASS_PORTFOLIO_${VAR_RANDOM}"

  #  Then I expect Shareclass Account Master "3792_SHARECLASS_PORTFOLIO_${VAR_RANDOM}" is updated as below
  #    | Traditional Chinese Long Name  | 3792_${VAR_RANDOM}_TRD_LONG_NAME_NEW |
  #    | Traditional Chinese Short Name | 3792_${VAR_RANDOM}_TRD_LONG_NAME_NEW |
  #    | Hedge Portfolio Name           | MFAW0001                             |
  #    | Taiwan Uniform Business Number | 3792_${VAR_RANDOM}_UNI_BUS_NUM_NEW   |
  #    | Taiwan SITCA Fund ID           | 3792_${VAR_RANDOM}_SITCA_FUNDID_NEW  |

  #  Then I close GS tab "GlobalSearch"

  Scenario: Close browsers
    Then I close all opened web browsers