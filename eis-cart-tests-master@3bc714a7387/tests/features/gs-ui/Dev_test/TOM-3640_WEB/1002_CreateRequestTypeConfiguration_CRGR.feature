#https://jira.intranet.asia/browse/TOM-3355
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498

@web @tom_3640 @gs_ui_regression @gc_ui_worklist
@gc_ui_cross_reference_group @gc_ui_request_type_configuration
Feature: Create RequestTypeConfiguration for central cross reference group linkage with vendor request

  Understand that some of the requirements to for managing Custom data SOI for Fund and Security type are not available in DMP Out Of Box and was not developed.
  This was a requirement which went missing.

  UI for managing SOI for Fund and Sec type is required to reduce the cost and manage user requests effectively without Development team's help

  This requirement is to allow business to maintain the underlying configuration to support the CDF request.
  To fit the tight timeline of R3, some parameters are hard coded and it is not sustainable and timely react to business changes.

  This feature file can be used to check the RequestTypeConfiguration create functionality over UI.
  This handles both the maker checker event require to create RequestTypeConfiguration.

  Scenario: TC_1: Prerequisites before running actual tests : Create New Central Cross Reference Group for Portfolio and Security type combination

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I create a new Central Cross Reference Group along with a new Participant Details
      | Group Purpose       | Universe                            |
      | Group Type          | Security Type Group                 |
      | Group Name          | 3640_CCR_${VAR_RANDOM}              |
      | Group Description   | 3640_TEST-SEC-TYP-GROUP-DESCRIPTION |
      | Participant Purpose | Member                              |
      | Classification Name | BRS Security Group - ABS            |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "3640_CCR_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3640_CCR_${VAR_RANDOM}"
    When I relogin to golden source UI with "task_assignee" role
    Then I expect Central Cross Reference Group "3640_CCR_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Create New RequestTypeConfiguration for central cross reference group linkage with vendor request

    Given I login to golden source UI with "task_assignee" role

    When I create a new Request Type Configuration with below details
      | Central Cross Reference Group | 3640_CCR_${VAR_RANDOM}       |
      | Vendor Request Type           | EIS_Creditrisk               |
      | Configuration Description     | 3640_RT_Config_${VAR_RANDOM} |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "3640_RT_Config_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3640_RT_Config_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Request Type Configuration is created with below value
      | Central Cross Reference Group | 3640_CCR_${VAR_RANDOM}       |
      | Vendor Request Type           | EIS_Creditrisk               |
      | Configuration Description     | 3640_RT_Config_${VAR_RANDOM} |

  Scenario: Close browsers
    Then I close all opened web browsers

