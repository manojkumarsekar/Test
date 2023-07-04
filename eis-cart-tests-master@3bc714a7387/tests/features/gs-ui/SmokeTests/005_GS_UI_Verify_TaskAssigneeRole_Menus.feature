@web @gs_ui_smoke @gs_ui_menu_verification @gs_ui_verify_task_assignee_menu
Feature: GS Portal Smoke Test - Verify Task Assignee Role Menu

  The Data Management Platform (DMP) leverages the solutions from vendor Golden Source.
  One of the components of the Golden Source is the Golden Source Portal where users will
  be able to view and manage the data through the Web User Interface.

  This Smoke Test provides some assurance that the deployed application (portal) by
  performing basic tasks on the Web UI to ensure that the basic functionalities are still
  there (after new deployments, changes, or on periodic basis).

  Scenario: Launch GS UI
    Given I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying Security Master <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu        | SubMenu                       |
      | Security Master | Issue                         |
      | Security Master | Instrument Group              |
      | Security Master | Issue Type                    |
      | Security Master | Issue Type Group              |
      | Security Master | Issue Ratings                 |
      | Security Master | Financial Market              |
      | Security Master | Market Group                  |
      | Security Master | Institution                   |
      | Security Master | Institution Role              |
      | Security Master | Institution Ratings           |
      | Security Master | Publishing Log                |
      | Security Master | Publishing Log Report         |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying Customer Master <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu        | SubMenu                 |
      | Customer Master | Customer                |
      | Customer Master | Account Master          |
      | Customer Master | Financial Professionals |


  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying Pricing  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu | SubMenu                       |
      | Pricing  | Pricing Exceptions            |
      | Pricing  | Issue Price                   |
      | Pricing  | Price Validation Instructions |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying Benchmark Master  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu         | SubMenu   |
      | Benchmark Master | Benchmark |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying AuditLog  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu | SubMenu          |
      | AuditLog | Audit Log Report |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying Generic Setup  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu      | SubMenu                              |
      | Generic Setup | Geographic Unit                      |
      | Generic Setup | Geographic Unit Group                |
      | Generic Setup | Country Information                  |
      | Generic Setup | Address                              |
      | Generic Setup | Statistic Definition                 |
      | Generic Setup | External Field Definition            |
      | Generic Setup | Internal Domain For Data Field       |
      | Generic Setup | Internal Domain For Data Field Class |
      | Generic Setup | Industry Classification Set          |
      | Generic Setup | Document Definition                  |
      | Generic Setup | Industry Relationship                |
      | Generic Setup | Rating Set Definition                |
      | Generic Setup | Calendar Definition                  |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying Exception Management  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu             | SubMenu                   |
      | Exception Management | Load Error Report         |
      | Exception Management | Transactions & Exceptions |
      | Exception Management | EOI for Exceptions        |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying DataLineage  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu    | SubMenu      |
      | DataLineage | Traceability |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "task_assignee" role

  Scenario Outline: Verifying My Worklist  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu    | SubMenu                     |
      | My Worklist | My Worklist                 |
      | My Worklist | Vendor Data Compare Details |


  Scenario: Close browsers
    Then I close all opened web browsers
