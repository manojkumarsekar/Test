#https://jira.intranet.asia/browse/TOM-3353
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498

@web @tom_3353 @gs_ui_regression @tom_3374 @1002_update_crgr @gc_ui_cross_reference_group
Feature: Update Central Cross Reference Group

  Understand that some of the requirements to for managing Custom data SOI for Fund and Security type are not available in DMP Out Of Box and was not developed.
  This was a requirement which went missing.

  UI for managing SOI for Fund and Sec type is required to reduce the cost and manage user requests effectively without Development team's help

  This requirement is to allow business to maintain the underlying configuration to support the CDF request.
  To fit the tight timeline of R3, some parameters are hard coded and it is not sustainable and timely react to business changes.

  This feature file can be used to check the Central Cross Reference Group update functionality over UI.
  This handles both the maker checker event require to update Central Cross Reference Group.

  Scenario: Update New Central Cross Reference Group for Portfolio and Security type combination

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a new Central Cross Reference Group along with a new Participant Details
      | Group Purpose        | Universe                                 |
      | Group Type           | Portfolio and Security Type Group        |
      | Group Name           | TEST3353_GRP_${VAR_RANDOM}               |
      | Group Description    | TOM_3353_PORT-SEC-TYP-GROUP-DESCRIPTION  |
      | Participant Purpose  | Member                                   |
      | Portfolio Group Name | Group 1 to request BB Secmaster category |

    And I add Participant Details to the Central Cross Reference Group
      | Participant Purpose | Member                                                   |
      | Classification Name | RDM Security Classfication - American Depository Receipt |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST3353_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    And I update Central Cross Reference Group "TEST3353_GRP_${VAR_RANDOM}" with below details
      | Group Description       | GRP DESC UPDATED |
      | Participant Description | CHECK FOR UPDATE |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TEST3353_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TEST3353_GRP_${VAR_RANDOM}"

    Then I expect Central Cross Reference Group "TEST3353_GRP_${VAR_RANDOM}" is updated as below
      | Group Description       | GRP DESC UPDATED |

    Then I expect Central Cross Reference Group "TEST3353_GRP_${VAR_RANDOM}" Participant details are updated as below
      | Participant Description | CHECK FOR UPDATE |

  Scenario: Close browsers
    Then I close all opened web browsers
