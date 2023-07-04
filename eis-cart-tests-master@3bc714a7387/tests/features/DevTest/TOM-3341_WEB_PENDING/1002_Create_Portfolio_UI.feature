@tom_3341
Feature: Loading different files to populate FT_T_FPRO(FinancialServicesProfessional)

  Scenario: TC_5: Verify Is Portfolio Manager field is present on search

    Given I login to golden source UI with "task_assignee" role

    When I search Financial Professionals with below details
      | Is Portfolio manager | Yes                       |
      | Fins Pro ID          | luiz.pinho@eastspring.com |

    Then I expect GS table should have 1 rows

  Scenario: TC_6: Create New Financial Professionals and Update Is Portfolio Manager and Verify

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a new Financial Professionals with below details
      | Fins Pro ID          | abc${VAR_RANDOM}.def@eastspring.com |
      | Portfolio Domicile   | SG-Singapore                        |
      | First Name           | abc${VAR_RANDOM}                    |
      | Last Name            | def                                 |
      | Is Portfolio Manager | Yes                                 |
      | BRS Initials         | CXH                                 |
      | BRS Login            | p9lpinho                            |

    And I save changes

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "abc${VAR_RANDOM}.def@eastspring.com"

    When I relogin to golden source UI with "task_assignee" role

    When I update Financial Professionals "abc${VAR_RANDOM}.def@eastspring.com" with below details
      | Is Portfolio Manager | null |

    And I save changes

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "abc${VAR_RANDOM}.def@eastspring.com"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Financial Professionals "abc${VAR_RANDOM}.def@eastspring.com" is updated as below
      | Is Portfolio Manager | null |

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_7: Create and then Update Portfolio/Account Master new fields

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create account master with following details
      | Portfolio Name              | 3341_PORTFOLIO_${VAR_RANDOM}               |
      | Portfolio Legal Name        | 3341_PORTFOLIO_${VAR_RANDOM}               |
      | Inception Date              | T                                          |
      | Base Currency               | USD-US Dollar                              |
      | Processed/Non Processed     | NON-PROCESSED                              |
      | Fund Region                 | NONLATAM                                   |
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |
      | CRTS Portfolio Code         | 3341_${VAR_RANDOM}_CRTS                    |
      | TSTAR Portfolio Code        | 3341_${VAR_RANDOM}_TSTAR                   |
      | Korea MD Portfolio Code     | 3341_${VAR_RANDOM}_KOREA                   |
      | IRP Code                    | 3341_${VAR_RANDOM}_IRP                     |
      | Portfolio Manager 1         | ilene.chong@eastspring.com                 |

    And I save changes

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3341_PORTFOLIO_${VAR_RANDOM}"

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_8: Create and then Update Portfolio/Account Master new fields

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create account master with following details
      | Portfolio Name              | 3341_PORTFOLIO_${VAR_RANDOM}               |
      | Portfolio Legal Name        | 3341_PORTFOLIO_${VAR_RANDOM}               |
      | Inception Date              | T                                          |
      | Base Currency               | USD-US Dollar                              |
      | Processed/Non Processed     | NON-PROCESSED                              |
      | Fund Region                 | NONLATAM                                   |
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |
      | CRTS Portfolio Code         | 3341_${VAR_RANDOM}_CRTS                    |
      | TSTAR Portfolio Code        | 3341_${VAR_RANDOM}_TSTAR                   |
      | Korea MD Portfolio Code     | 3341_${VAR_RANDOM}_KOREA                   |
      | IRP Code                    | 3341_${VAR_RANDOM}_IRP                     |

    And I save changes

    When I Click on "Portfolio Manager 1" field seacrh button
    Then In the "Portfolio Manager 1" popup screen "Is Portfolio Manager" field should be repsent with filtered YES

  Scenario: Close browsers
    Then I close all opened web browsers


