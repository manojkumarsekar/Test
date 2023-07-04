#https://jira.intranet.asia/browse/TOM-3352
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498

@web @tom_3352 @gs_ui_regression @eisdev_6766 @gc_ui_account_group
Feature: Update AccountGroup

  This feature file can be used to check the AccountGroup update functionality over UI.
  This handles both the maker checker event require to update AccountGroup.

	EISDEV-6766 18/08/2020 : fetch FUND portfolio, to align to default search setting for accounts

  Scenario: TC_1: Prerequisites before running actual tests : Get a Portfolio Name from Database

    Given I execute below query and extract values of "PORTFOLIO" into same variables
    """
    select * from
      (
        select ACCT_NME as PORTFOLIO from FT_T_ACCT
        where ACCT_STAT_TYP = 'OPEN'
        and DATA_STAT_TYP = 'ACTIVE'
        and ACTP_ACCT_TYP = 'FUND'
        order by ACCT_OPEN_DTE desc
      )
    where rownum = 1
    """

  Scenario: TC_2: Create New Account Group and Update Group Purpose and Verify

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a new Account Group with below details
      | Group ID          | 3352_AccntGrpID3_${VAR_RANDOM}   |
      | Group Name        | 3352_AccntGrpName3_${VAR_RANDOM} |
      | Group Purpose     | Universe                         |
      | Group Description | 3352_TestAccntGrp3               |

    And I add Participant Details to the Account Group
      | Portfolio Name          | ${PORTFOLIO}                   |
      | Participant Purpose     | Member                         |
      | Participant Description | 3352_TestAccntGrp3 Participant |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "3352_AccntGrpID3_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    When I update Account Group "3352_AccntGrpID3_${VAR_RANDOM}" with below details
      | Group Purpose | BROKERS |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "3352_AccntGrpID3_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Group "3352_AccntGrpID3_${VAR_RANDOM}" is updated as below
      | Group Purpose | Brokers |

  Scenario: Close browsers
    Then I close all opened web browsers
