# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 27/02/2020     EISDEV-6108    Initial Version
# =====================================================================
#https://jira.pruconnect.net/browse/EISDEV-6108 - This ticket is as error getting encountered due to rule deriving RDM Sec Type.
# Because of which its throwing error while perfroming save action on UI , So we have fixed JavaRule for the same.
#https://jira.pruconnect.net/browse/EISDEV-6288 : Updating generic steps with new steps

@eisdev_6108 @web @gs_ui_regression @eisdev_6288 @eisdev_7240
@gc_ui_instrument

Feature: Update an Issue Description and Denominated currency
  As a user I should able to update Issue Description and Denominated currency details over UI.

  Scenario: Update Issue Description
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "ABS CBN ORD" to variable "INTSR_NAME"

    * I execute below query to "ensure no pending records for ${INTSR_NAME} "
    """
    delete from ft_wf_uiwa
    where main_entity_nme = '${INTSR_NAME}'
    and USER_INSTRUC_TXT is null;
    commit
    """

    And I open existing Issue "${INTSR_NAME}"
    And I update below issue description details
      | Instrument Description | ${INTSR_NAME}_${VAR_RANDOM} |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_assignee" role

    And I open existing Issue "${INTSR_NAME}"

    Then I expect below issue description details updated
      | Instrument Description | ${INTSR_NAME}_${VAR_RANDOM} |


  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: Update Denominated Currency

    Given I login to golden source UI with "task_assignee" role
    And I assign "ABS CBN ORD" to variable "INTSR_NAME"
    And I open existing Issue "${INTSR_NAME}"
    And I update below instrument details
      | Denominated Currency | SGD - Singapore Dollar |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect below instrument details updated for the Issue "${INTSR_NAME}"
      | Denominated Currency | SGD - Singapore Dollar |

  Scenario: Close browsers
    Then I close all opened web browsers
