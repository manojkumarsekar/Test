@web @gs_ui_regression @eisdev_6807 @gc_ui_instrument @gc_ui_worklist

  #EISDEV-6807 - Added Proxy in BRS validation
  
Feature: Create and update an Issue
  This feature file can be used to check the Issue update functionality over UI.
  This handles both the maker checker event require to update Issue.

  Scenario: Update Issue
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "TST_INSTNAME_${VAR_RANDOM}" to variable "INTSR_NAME"

    When I enter below Instrument Details for new Issue
      | Instrument Name          | ${INTSR_NAME}           |
      | Instrument Description   | TST_INSTDESC            |
      | Instrument Type          | Equity Share            |
      | Pricing Method           | 100 Pieces              |
      | Instrument System Status | Active                  |
      | Source Currency          | HKD - Hong Kong Dollar  |
      | Target Currency          | AUD - Australian Dollar |
      | Proxy in BRS             | Yes                     |



    And I add below Market Listing details
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |

    And I add below Market level Identifiers under Market Listing
      | RDM Code | RDM_${VAR_RANDOM} |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_assignee" role

    And I open existing Issue "${INTSR_NAME}"
    And I update below instrument details
      | Source Currency | SGD - Singapore Dollar |
      | Target Currency | USD - US Dollar        |
      | Proxy in BRS    | No                     |


    And I save the valid data
    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect below instrument details updated for the Issue "${INTSR_NAME}"
      | Source Currency | SGD - Singapore Dollar |
      | Target Currency | USD - US Dollar        |
      | Proxy in BRS    | No                     |


