#https://jira.pruconnect.net/browse/EISDEV-6313

@web @gs_ui_regression @gs_ui_remove_normal_lock_via_datafeed @eisdev_6313 @eisdev_7240
@gc_ui_lock

Feature: Remove normal lock via data feed
  This feature file can be used to check the below scenarios
  1. Normal lock could be removed by loading data through data uploader directly into DMP

  Scenario: TC1: Assign variables and create portfolio as prerequisite



    Given I assign "UI Lock Functionality Port 1" to variable "PORTFOLIO_NAME"
    And I assign "Portfolio Name" to variable "FIELD_NAME"
    And I assign "Lock_Functionality_Portfolio_Creation_Prerequisite.xlsx" to variable "PORTFOLIO_INPUT_FILENAME"
    And I assign "003_GS_UI_Remove_Normal_Lock_Using_Data_Feed.xlsx" to variable "PORTFOLIO_UPDATE_FILENAME"
    And I assign "003_GS_UI_Remove_Normal_Lock_Data_Feed_With_Different_Values.xlsx" to variable "PORTFOLIO_UPDATE_DIFF_DATA"
    And I assign "tests/test-data/gs-ui/regression/lockfunctionality" to variable "testdata.path"

    When I process "${testdata.path}/${PORTFOLIO_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: TC2: Apply normal lock to a field for an existing portfolio

    * I execute below query to "ensure no pending records for ${PORTFOLIO_NAME} "
    """
    delete from ft_wf_uiwa
    where main_entity_nme = '${PORTFOLIO_NAME}'
    and USER_INSTRUC_TXT is null;
    commit
    """

    Given I login to golden source UI with "task_assignee" role

    When I open "Account:${PORTFOLIO_NAME}" from global search
    And I add "Normal" lock for "${FIELD_NAME}" field
    And I save the valid data

    Then I expect a record in My WorkList with entity name "${PORTFOLIO_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${PORTFOLIO_NAME}"

    And I relogin to golden source UI with "task_assignee" role
    And I open "Account:${PORTFOLIO_NAME}" from global search

    Then I should see the "${FIELD_NAME}" is locked using "Normal" lock

  Scenario: TC3: Loading different values via data feed does not remove the lock

    When I process "${testdata.path}/${PORTFOLIO_UPDATE_DIFF_DATA}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPDATE_DIFF_DATA}        |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    And I login to golden source UI with "task_assignee" role

    And I open "Account:${PORTFOLIO_NAME}" from global search
    Then I should see the "${FIELD_NAME}" is locked using "Normal" lock

  Scenario: TC4: Remove normal lock by using data load via data feed

    When I process "${testdata.path}/${PORTFOLIO_UPDATE_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPDATE_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    And I login to golden source UI with "task_assignee" role

    And I open "Account:${PORTFOLIO_NAME}" from global search
    Then I should see the "Normal" lock from the "${FIELD_NAME}" is removed