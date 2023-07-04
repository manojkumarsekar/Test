#https://jira.intranet.asia/browse/TOM-4710
# eisdev_7180 - Account master enhancements for breaking the BDD

@tom_4710 @web @gs_ui_regression @tom_4787 @eisdev_7180
@gc_ui_account_master

Feature: Update Account Master for TT56

  Scenario: TC_1: Update Investment Team for portfolio TT56

    * I assign "ESP9538938" to variable "PORTFOLIO_CODE"
    * I assign "EASTSPRING INVESTMENTS ASIAN INCOME BALANCED FUND" to variable "PORTFOLIO_NAME"

    * I execute below query to "ensure no pending records for ${PORTFOLIO_NAME} "
    """
    delete from ft_wf_uiwa
    where main_entity_nme = '${PORTFOLIO_NAME}'
    and USER_INSTRUC_TXT is null;
    commit
    """

    Given I login to golden source UI with "task_assignee" role

    Given I open account master "${PORTFOLIO_CODE}" for the given portfolio

    When I update portfolio details in account master with following details
      | Investment Team | GAA-GLOBAL ASSET ALLOCATION |

    And I save the modified data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${PORTFOLIO_NAME}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "${PORTFOLIO_CODE}" for the given portfolio

    Then I update portfolio details in account master with following details
      | Investment Team | B-BALANCED |

    And I save the modified data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${PORTFOLIO_NAME}"

    Then I expect Account Master "${PORTFOLIO_CODE}" is created

    Then I expect portfolio details in Account Master is updated as below
      | Investment Team | B-BALANCED |



