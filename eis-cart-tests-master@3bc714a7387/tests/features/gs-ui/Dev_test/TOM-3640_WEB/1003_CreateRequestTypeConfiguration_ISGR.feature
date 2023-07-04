#https://jira.intranet.asia/browse/TOM-3355
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498
#As part of EISDEV-6907, Look up on Instrument Group screen has changed from Instrument Name to Preferred Identifier Value

@web @tom_3640 @gs_ui_regression @eisdev_7007 @gc_ui_instrument_group @gc_ui_request_type_configuration @eisdev_7369
Feature: Create RequestTypeConfiguration for issue group linkage with vendor request

  Understand that some of the requirements to for managing Custom data SOI for Fund and Security type are not available in DMP Out Of Box and was not developed.
  This was a requirement which went missing.

  UI for managing SOI for Fund and Sec type is required to reduce the cost and manage user requests effectively without Development team's help

  This requirement is to allow business to maintain the underlying configuration to support the CDF request.
  To fit the tight timeline of R3, some parameters are hard coded and it is not sustainable and timely react to business changes.

  This feature file can be used to check the RequestTypeConfiguration create functionality over UI.
  This handles both the maker checker event require to create RequestTypeConfiguration.

  Scenario: TC_1: Prerequisites before running actual tests : Create New Instrument Group

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I create Instrument Group with following details
      | Group ID               | 3640_GRPID_${VAR_RANDOM}  |
      | Group Name             | 3640_INSGRP_${VAR_RANDOM} |
      | Group Purpose          | Account Download          |
      | Group Description      | 3640_TST_GROUPDESC        |
      | Subscriber/Down Stream | BNP_CASHALLOC_ITAP        |
      | Enterprise             | EIS                       |
      | Asset Subdivision Name |                           |
      | Group Created On       | T                         |
      | Group Effective Until  |                           |

    When I add Instrument Group Participant with following details
      | Participant Purpose         | Acceleration Clause   |
      | Participant Description     | Test_Participant_DESC |
      | Participant Amount          | 500                   |
      | Participant Percent         | 5                     |
      | Participant Currency        | 10  - Old Krona (old) |
      | Participation Type          | Amount                |
      | Participant Created On      | T                     |
      | Participant Effective Until |                       |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "3640_INSGRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "3640_INSGRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Instrument Group "3640_INSGRP_${VAR_RANDOM}" is created

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Create New RequestTypeConfiguration for issue group linkage with vendor request

    Given I login to golden source UI with "task_assignee" role

    When I create a new Request Type Configuration with below details
      | Issue Group Name          | 3640_INSGRP_${VAR_RANDOM}  |
      | Vendor Request Type       | EIS_Secmaster              |
      | Configuration Description | 3640_ISGRGrp_${VAR_RANDOM} |

    And I save the valid data
    Then I expect a record in My WorkList with entity name "3640_ISGRGrp_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3640_ISGRGrp_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Request Type Configuration is created with below value
      | Issue Group Name          | 3640_INSGRP_${VAR_RANDOM}  |
      | Vendor Request Type       | EIS_Secmaster              |
      | Configuration Description | 3640_ISGRGrp_${VAR_RANDOM} |

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_3: Create New RequestTypeConfiguration for issue group linkage with vendor request

    Given I login to golden source UI with "task_assignee" role

    When I search Request Type Configuration with below value
      | Configuration Description | 3640_ISGRGrp_${VAR_RANDOM} |

    And I update Request Type Configuration with below details
      | Vendor Request Type | Generic |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "3640_ISGRGrp_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Request Type Configuration is updated as below
      | Configuration Description | 3640_ISGRGrp_${VAR_RANDOM} |
      | Vendor Request Type       | Generic                    |

  Scenario: Close browsers
    Then I close all opened web browsers

