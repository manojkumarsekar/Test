@web @gs_ui_smoke @gs_ui_menu_verification @gs_ui_verify_admin_menu
Feature: GS Portal Smoke Test - Verify Administrator Role Menu

  The Data Management Platform (DMP) leverages the solutions from vendor Golden Source.
  One of the components of the Golden Source is the Golden Source Portal where users will
  be able to view and manage the data through the Web User Interface.

  This Smoke Test provides some assurance that the deployed application (portal) by
  performing basic tasks on the Web UI to ensure that the basic functionalities are still
  there (after new deployments, changes, or on periodic basis).

  Scenario: Launch GS UI
    Given I login to golden source UI with "administrators" role

  Scenario Outline: Verifying Security Master <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu        | SubMenu                             |
      | Security Master | Issue                               |
      | Security Master | Instrument Group                    |
      | Security Master | Issue Type                          |
      | Security Master | Issue Type Group                    |
      | Security Master | Issue Rating Opinions               |
      | Security Master | Issue Ratings                       |
      | Security Master | Underlying Issue                    |
      | Security Master | Mortgage Pool Prefix                |
      | Security Master | Property Document                   |
      | Security Master | Mortgage Aggregation                |
      | Security Master | Mortgage Aggregation History        |
      | Security Master | Request for Issues                  |
      | Security Master | Vendor Request Schedule             |
      | Security Master | Vendor Request Management           |
      | Security Master | Issuer                              |
      | Security Master | Issuer Group                        |
      | Security Master | Issuance Conflict Match             |
      | Security Master | Issuance Likely Match               |
      | Security Master | Exclude Criteria                    |
      | Security Master | Financial Market                    |
      | Security Master | Market Group                        |
      | Security Master | PSET-Subcustodian Master            |
      | Security Master | Financial Institution (Multientity) |
      | Security Master | Institution                         |
      | Security Master | Institution Group                   |
      | Security Master | Institution Role                    |
      | Security Master | Institution Role Group              |
      | Security Master | Institution Hierarchy               |
      | Security Master | Institution Ratings                 |
      | Security Master | Institution Rating Opinions         |
      | Security Master | Trade                               |
      | Security Master | CA Declaration                      |
      | Security Master | CA Type                             |
      | Security Master | CA Type Group                       |
      | Security Master | CA Merge                            |
      | Security Master | CA Eligibility                      |
      | Security Master | CA Related Events Query             |
      | Security Master | Downstream System Definition        |
      | Security Master | Publishing Log                      |
      | Security Master | Publishing Log Report               |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying Customer Master <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu        | SubMenu                              |
      | Customer Master | Customer                             |
      | Customer Master | Employee                             |
      | Customer Master | Customer Type                        |
      | Customer Master | Account                              |
      | Customer Master | Account Master                       |
      | Customer Master | Account Type                         |
      | Customer Master | Account Type Group                   |
      | Customer Master | External Account Search              |
      | Customer Master | Internal Account Purpose             |
      | Customer Master | Product                              |
      | Customer Master | Product Group                        |
      | Customer Master | Product Feature                      |
      | Customer Master | Product Line                         |
      | Customer Master | Product Feature Character Definition |
      | Customer Master | Book Of Accounts                     |
      | Customer Master | Enterprise                           |
      | Customer Master | Subdivisions                         |
      | Customer Master | Enterprise Group                     |
      | Customer Master | Financial Institution                |
      | Customer Master | Issuer                               |
      | Customer Master | Legal Owner                          |
      | Customer Master | Account                              |
      | Customer Master | Document Definition                  |
      | Customer Master | Financial Professionals              |
      | Customer Master | Dealer                               |
      | Customer Master | Dealer Group                         |
      | Customer Master | Dealer Representative Group          |
      | Customer Master | Financial Services Professional      |
      | Customer Master | Consulting Firm                      |
      | Customer Master | Marketing Division                   |
      | Customer Master | Marketing Group                      |
      | Customer Master | New Dealer Merge Instructions        |
      | Customer Master | Edit Dealer Merge Instructions       |
      | Customer Master | New Branch Merge Instructions        |
      | Customer Master | Edit Branch Merge Instructions       |
      | Customer Master | Table Merge Instructions             |
      | Customer Master | Phone Update Instructions            |
      | Customer Master | Legal Agreement                      |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying Pricing  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu | SubMenu                       |
      | Pricing  | Pricing Exceptions            |
      | Pricing  | Issue Price                   |
      | Pricing  | Snap Time                     |
      | Pricing  | Vendor Hierarchy              |
      | Pricing  | Price Validation Instructions |
      | Pricing  | Configure Rules               |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying Benchmark Master  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu         | SubMenu                        |
      | Benchmark Master | Simple Benchmark               |
      | Benchmark Master | Blended Benchmark              |
      | Benchmark Master | Enable/Disable Benchmark       |
      | Benchmark Master | Constituent Participation      |
      | Benchmark Master | Benchmark / Participant Search |
      | Benchmark Master | Benchmark                      |
      | Benchmark Master | Vendor Benchmark               |
      | Benchmark Master | Benchmark & Index Type         |
      | Benchmark Master | Benchmark Calculation Options  |
      | Benchmark Master | Benchmark Calculation          |
      | Benchmark Master | Ad hoc Rebalance               |
      | Benchmark Master | Vendor Corrections             |
      | Benchmark Master | Benchmark Correction Sequence  |
      | Benchmark Master | Benchmark Processing Status    |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying AuditLog  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu | SubMenu          |
      | AuditLog | Audit Log Report |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

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
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying Exception Management  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu             | SubMenu                   |
      | Exception Management | Load Error Report         |
      | Exception Management | Transactions & Exceptions |
      | Exception Management | EOI for Exceptions        |
      | Exception Management | Prioritize Exceptions     |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  #Admin -> GSO Designer screen is not Automatable in Bamboo as it involves Windows popup
  #Hence removing GSO Designer menu verification from Automation scope

  Scenario Outline: Verifying Admin  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu | SubMenu                          |
      | Admin    | Change Label                     |
      | Admin    | Core Data Setup                  |
      | Admin    | Entity Management                |
      | Admin    | Exceptions Severity              |
      | Admin    | Match Key Creation               |
      | Admin    | Model Definition                 |
      | Admin    | Manage Template                  |
      | Admin    | Notification Definition          |
      | Admin    | Rule UI Configuration            |
      | Admin    | VSH Configuration                |
      | Admin    | Listing Level Configuration      |
      | Admin    | Application Users                |
      | Admin    | Application User Group           |
      | Admin    | Application Roles                |
      | Admin    | Class Identifiers                |
      | Admin    | Entitlements                     |
      | Admin    | Workflow Enabled Models          |
      | Admin    | Workflow Enabled GSO             |
      | Admin    | Listing Identifier Configuration |
      #| Admin    | GSO Designer                     |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying DataLineage  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu    | SubMenu      |
      | DataLineage | Traceability |

  Scenario: Close browsers and Login again
    Then I close all opened web browsers
    And I login to golden source UI with "administrators" role

  Scenario Outline: Verifying My Worklist  <MainMenu>::<SubMenu>
    When  I select from GS menu "<MainMenu>::<SubMenu>"
    Then I expect "<SubMenu>" screen is opened
    And I close GS tab "<SubMenu>"

    Examples:
      | MainMenu    | SubMenu                              |
      | My Worklist | My Worklist                          |
      | My Worklist | Vendor Data Compare Details          |
      | My Worklist | Issue Completeness - Missing Fields  |
      | My Worklist | Issue Completeness - By Asset        |
      | My Worklist | Issue Completeness - By Asset & Date |
      | My Worklist | Price Exception Details              |
      | My Worklist | Price Exception Summary              |
      | My Worklist | Change Approvals                     |
      | My Worklist | Locked Fields Summary                |
      | My Worklist | Customer Worklist                    |
      | My Worklist | Customer Amend                       |
      | My Worklist | Customer Onboarding                  |
      | My Worklist | Products & Limits                    |


  Scenario: Close browsers
    Then I close all opened web browsers
