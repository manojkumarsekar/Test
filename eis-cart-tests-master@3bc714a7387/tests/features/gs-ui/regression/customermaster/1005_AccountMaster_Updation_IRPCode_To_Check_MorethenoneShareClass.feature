#https://jira.intranet.asia/browse/TOM-4003
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+portfolio+and+share+class+requirement#businessRequirements--673930711
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48892955
# eisdev_7180 - Account master enhancements for breaking the BDD

@tom_4003 @web @gs_ui_regression @tom_4787 @eisdev_6874 @gc_ui_account_master @eisdev_7180
Feature: Update Account Master to check more then one shareclass in Portfolio hierarchy.

  Enable the Nature Key for EISShareClassAccount GSO and Portfolio Hierarchy Datagroup, if this nature key is not available then we are not able to update the UI.

  This feature file is to test the more then one shareclass in Portfolio hierarchy in Account master UI using maker checker event.

  Scenario: TC_1: Update IRP Code field with value to check more then one shareclass in Portfolio hierarchy

    *  I assign "EASTSPRING INVESTMENTS - ASIAN INVESTMENT GRADE BOND FUND" to variable "PORTFOLIO_NAME"
    *  I execute below query to "ensure no pending records for ${PORTFOLIO_NAME}"
    """
    delete from ft_wf_uiwa
    where main_entity_nme like '${PORTFOLIO_NAME}'
    and USER_INSTRUC_TXT is null;
    commit;
    """
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"


    Given I open account master "${PORTFOLIO_NAME}" for the given portfolio

    Then I update portfolio details in account master with following details
      | Processed/Non Processed | PROCESSED |

    Then I update Fund Details in account Master as below
      | Fund Category | LIFE - LIFE |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${PORTFOLIO_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${PORTFOLIO_NAME}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "${PORTFOLIO_NAME}" for the given portfolio

    Then I expect portfolio details in Account Master is updated as below
      | Processed/Non Processed | PROCESSED |

    Then I expect fund details in Account Master is updated as below
      | Fund Category | LIFE - LIFE |

    Then I close GS tab "GlobalSearch"



