@web @gs_ui_regression @eisdev_5275
@gc_ui_instrument
Feature: Create new Issue with Broker Code as Extended Identifier
  The feature file is used to setup Broker fund code as Instrument Identifier.

  Scenario: Create Issue with Broker Code
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

    And I add below Market Listing details
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |

    And I add below Market level Identifiers under Market Listing
      | RDM Code | RDM_${VAR_RANDOM} |

    And I add below Extended Identifier
      | Identifier Value          | BRCODE_${VAR_RANDOM} |
      | Identifier Type           | BROKERFUNDCD         |
      | Identifier Effective Date | T                    |
      | Global Unique Indicator   | No                   |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_assignee" role

    Then I expect Issue "${INTSR_NAME}" is created

  Scenario: Close browsers
    Then I close all opened web browsers
