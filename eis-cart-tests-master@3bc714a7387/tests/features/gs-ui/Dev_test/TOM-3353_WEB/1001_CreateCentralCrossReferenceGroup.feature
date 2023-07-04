#https://jira.intranet.asia/browse/TOM-3353
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498

@web @tom_3353 @gs_ui_regression @tom_3374 @1001_create_crgr @gc_ui_cross_reference_group
Feature: Create Central Cross Reference Group and its participant as portfolio and security type

  Understand that some of the requirements to for managing Custom data SOI for Fund and Security type are not available in DMP Out Of Box and was not developed.
  This was a requirement which went missing.

  UI for managing SOI for Fund and Sec type is required to reduce the cost and manage user requests effectively without Development team's help

  This requirement is to allow business to maintain the underlying configuration to support the CDF request.
  To fit the tight timeline of R3, some parameters are hard coded and it is not sustainable and timely react to business changes.

  This feature file can be used to check the CentralCrossReferenceGroup create functionality over UI.
  This handles both the maker checker event require to create CentralCrossReferenceGroup.

  Scenario: TC_1: Create New Central Cross Reference Group for Portfolio and Security type combination

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "dHms" and assign to variable "VAR_RANDOM"

    When I create a new Central Cross Reference Group along with a new Participant Details
      | Group Purpose        | Universe                                 |
      | Group Type           | Portfolio and Security Type Group        |
      | Group Name           | TEST3353_GRP1_${VAR_RANDOM}               |
      | Group Description    | TOM_3353_PORT-SEC-TYP-GROUP-DESCRIPTION  |
      | Participant Purpose  | Member                                   |
      | Portfolio Group Name | Group 1 to request BB Secmaster category |

    And I add Participant Details to the Central Cross Reference Group
      | Participant Purpose | Member                                                   |
      | Classification Name | RDM Security Classfication - American Depository Receipt |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TEST3353_GRP1_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST3353_GRP1_${VAR_RANDOM}"
    When I relogin to golden source UI with "task_assignee" role
    Then I expect Central Cross Reference Group "TEST3353_GRP1_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: Create New Central Cross Reference Group for Portfolio and Security type combination

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "dHMs" and assign to variable "VAR_RANDOM"

    When I create a new Central Cross Reference Group with below details
      | Group Purpose     | Universe                       |
      | Group Type        | Security Type Group            |
      | Group Name        | TEST3353_GRP2_${VAR_RANDOM}     |
      | Group Description | TEST-SEC-TYP-GROUP-DESCRIPTION |

    And I add Participant Details to the Central Cross Reference Group
      | Participant Purpose | Member                                    |
      | Classification Name | RDM Security Classfication - Asset Backed |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TEST3353_GRP2_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST3353_GRP2_${VAR_RANDOM}"
    When I relogin to golden source UI with "task_assignee" role
    Then I expect Central Cross Reference Group "TEST3353_GRP2_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers