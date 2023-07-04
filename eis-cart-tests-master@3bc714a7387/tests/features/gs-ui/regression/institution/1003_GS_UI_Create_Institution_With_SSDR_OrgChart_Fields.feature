#https://jira.pruconnect.net/browse/EISDEV-7300 :Added Reuters Entity LEI controls under Identifiers tab

@web @gs_ui_regression @eisdev_5939 @eisdev_7300 @eisdev_7300_ui_institution
@gc_ui_institution @eisdev_7359

Feature: Create New Institution with SSDR Org Chart changes
  This feature file is used for creating new institution with new fields added for SSDR Org Chart
  EISDEV-7300:Added Reuters Entity LEI controls under Identifiers tab

  Scenario: Create New Institution with new SSDR Org Chart fields

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I add new Institution with following details
      | Parent Company               | Prudential Belife Insurance S.A. |
      | Institution Name             | Test_Institution1_${VAR_RANDOM}  |
      | Institution Description      | Test_Institution_DESC            |
      | Preferred Identifier Name    | AGENT                            |
      | Preferred Identifier Value   | Test_Identifier_VALUE            |
      | Country Of Incorporation     | United States (the)              |
      | Country Of Domicile          | Albania                          |
      | Institution Status           | Active                           |
      | Institution Status Date/Time | T                                |

    And I add Institution Identifiers with following details
      | Inhouse Identifier | ESIIDENT_${VAR_RANDOM}    |
      | BRS Issuer ID      | BRSISSUEID_${VAR_RANDOM}  |
      | HIP Broker ID      | HIPBROKERID_${VAR_RANDOM} |
      | Reuters Entity LEI | REUTERS_LEI_${VAR_RANDOM} |

    And I add LBU Identifiers with following details
      | Company Number          | Test_CompNo_${VAR_RANDOM}          |
      | RCR/LBU Legal Entity ID | Test_Legal_Entity_ID_${VAR_RANDOM} |

    And I add SSDR OrgChart Attributes with following details
      | Regulator                | Test_Regulator_${VAR_RANDOM}  |
      | Percent Owned            | 90.01                         |
      | SSDR Form 13F CIK        | From_13_CIK_${VAR_RANDOM}     |
      | SSDR Form 13F FileNumber | From_13_File_No_${VAR_RANDOM} |

    And I add Address Details with following details
      | Address Type   | Business                            |
      | Address Line 1 | 10 Marina Boulevard                 |
      | Address Line 2 | Marina Bay Financial Centre Tower 2 |
      | Country Name   | Singapore                           |


    And I save the valid data

    Then I expect a record in My WorkList with entity name "Test_Institution1_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "Test_Institution1_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Institution "Test_Institution1_${VAR_RANDOM}" is created
    Then I open Institution "Test_Institution1_${VAR_RANDOM}" record

    Then I expect Institution identifiers are updated as below
      | Reuters Entity LEI | REUTERS_LEI_${VAR_RANDOM} |

    Then I expect LBU Identifiers are created as below
      | Company Number          | Test_CompNo_${VAR_RANDOM}          |
      | RCR/LBU Legal Entity ID | Test_Legal_Entity_ID_${VAR_RANDOM} |

    Then I expect SSDR OrgChart Attributes are created as below
      | Regulator                | Test_Regulator_${VAR_RANDOM}  |
      | Percent Owned            | 90.01                         |
      | SSDR Form 13F CIK        | From_13_CIK_${VAR_RANDOM}     |
      | SSDR Form 13F FileNumber | From_13_File_No_${VAR_RANDOM} |

    Then I expect Address Details are created as below
      | Address Type   | Business                            |
      | Address Line 1 | 10 Marina Boulevard                 |
      | Address Line 2 | Marina Bay Financial Centre Tower 2 |
      | Country Name   | Singapore                           |

  Scenario: Close browsers
    Then I close all opened web browsers
