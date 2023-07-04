#https://jira.pruconnect.net/browse/EISDEV-5441
#Note : RDM Code Market level identifier validation is already covered as part of  '001_GS_UI_Create_And_Update_SecurityMaster.feature'

@web @gs_ui_regression @eisdev_5441 @skip_driver_quit
@gc_ui_instrument

Feature: Create New Issue by providing TICKER\RIC\BB Global\Reuters Ticker

  This feature file can be used to check the Issue create functionality over UI.
  This handles both negative flow without any Market level identifiers and positive flow with any of TICKER\RIC\BB Global\Reuters Ticker identifiers.

  Scenario: Verify User not allowed to create an Issue without any Market Level Identifiers
  System throws Error message pop up while authorising the Issue without any Market level Identifier

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "TST_INSTNAME_${VAR_RANDOM}" to variable "INTSR_NAME"

    When I enter below Instrument Details for new Issue
      | Instrument Name          | ${INTSR_NAME} |
      | Instrument Description   | TST_INSTDESC  |
      | Instrument Type          | Equity Share  |
      | Instrument System Status | Active        |

    And I add below Market Listing details
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |

    And I save the valid data
    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role

    And I expect a record in My WorkList with entity name "${INTSR_NAME}"
    And I click on authorize record from My WorkList with entity name "${INTSR_NAME}"
    Then I expect error message "Sorry, But Error Message Issued." on popup

  Scenario: Close browsers and ReLogin as test assignee role
    Given I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Create New Issue with <identifier_field>

    When I enter below Instrument Details for new Issue
      | Instrument Name          | ${INTSR_NAME}_<instrument_name> |
      | Instrument Description   | <identifier_field>_TST_INSTDESC |
      | Instrument Type          | Equity Share                    |
      | Instrument System Status | Active                          |
    And I add below Market Listing details
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |

    And I add below Market level Identifiers under Market Listing
      | <identifier_field> | <instrument_name>_${VAR_RANDOM} |

    And I save the valid data
    Examples:
      | identifier_field | instrument_name |
      | BB Global        | BB_GLOBAL       |
      | Ticker           | TICKER          |
      | Reuters Ticker   | REUTERS_TICKER  |
      | RIC              | RIC             |

  Scenario: Close browsers and ReLogin as authorize role
    Given I close all opened web browsers
    And I login to golden source UI with "task_authorizer" role

  Scenario Outline: Approve the issue <instrument_name>
    Given I approve a record from My WorkList with entity name "${INTSR_NAME}_<instrument_name>"
    And I close active GS tab
    Examples:
      | instrument_name |
      | BB_GLOBAL       |
      | TICKER          |
      | REUTERS_TICKER  |
      | RIC             |

  Scenario: Close browsers and ReLogin as assignee role

    Given I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verify  the issue <instrument_name> is created

    Then I expect Issue "${INTSR_NAME}_<instrument_name>" is created
    And I close active GS tab
    Examples:
      | instrument_name |
      | BB_GLOBAL       |
      | TICKER          |
      | REUTERS_TICKER  |
      | RIC             |

  Scenario: Close browsers
    Then I close all opened web browsers