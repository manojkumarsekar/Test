#https://jira.pruconnect.net/browse/EISDEV-7535
@web @gs_ui_regression @gc_ui_institution @eisdev_7359 @eisdev_7535

Feature: Update Institution
  This feature file can be used to check the Institution update functionality over UI.
  This handles both the maker checker event require to update Institution.

  Scenario: Update Institution

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "yyMMddHHmm" and assign to variable "VAR_RANDOM_LEG_ID"

    When I add new Institution with following details
      | Institution Name             | Test_Institution2_${VAR_RANDOM} |
      | Institution Description      | Test_Institution_DESC           |
      | Preferred Identifier Name    | AGENT                           |
      | Preferred Identifier Value   | Test_Identifier_VALUE           |
      | Country Of Incorporation     | United States (the)             |
      | Country Of Domicile          | Albania                         |
      | Institution Status           | Active                          |
      | Institution Status Date/Time | T                               |

    And I add Institution Identifiers with following details
      | Inhouse Identifier          | ESIIDENT_${VAR_RANDOM}       |
      | BRS Issuer ID               | BRSISSUEID_${VAR_RANDOM}     |
      | HIP Broker ID               | HIPBROKERID_${VAR_RANDOM}    |
      | BRS Counterparty Code       | BRSCPRTYCDE_${VAR_RANDOM}    |
      | BB Company ID               | BBCOMPID_${VAR_RANDOM}       |
      | Legal Entity Identifier     | LEGALEIDxx${VAR_RANDOM_LEG_ID} |
      | Reuters Party Id            | RTPARTYID_${VAR_RANDOM}      |
      | BB Composite Exchange       | BBCOMPEXCH_${VAR_RANDOM}     |
      | BRS Trade Counterparty Code | BRSTRDCPRTYCDE_${VAR_RANDOM} |
      | Generic FINS ID             | GENFINSID_${VAR_RANDOM}      |
      | Issuer Ticker               | ISSTICKER_${VAR_RANDOM}      |
      | Fins Mnemonic               | FINSMNEM_${VAR_RANDOM}       |
      | Reuters Organisation Id     | RTORGID_${VAR_RANDOM}        |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "Test_Institution2_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "Test_Institution2_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I open Institution "Test_Institution2_${VAR_RANDOM}" record

    And I expect Institution identifiers are updated as below
      | Inhouse Identifier          | ESIIDENT_${VAR_RANDOM}       |
      | BRS Issuer ID               | BRSISSUEID_${VAR_RANDOM}     |
      | HIP Broker ID               | HIPBROKERID_${VAR_RANDOM}    |
      | BRS Counterparty Code       | BRSCPRTYCDE_${VAR_RANDOM}    |
      | BB Company ID               | BBCOMPID_${VAR_RANDOM}       |
      | Legal Entity Identifier     | LEGALEIDxx${VAR_RANDOM_LEG_ID} |
      | Reuters Party Id            | RTPARTYID_${VAR_RANDOM}      |
      | BB Composite Exchange       | BBCOMPEXCH_${VAR_RANDOM}     |
      | BRS Trade Counterparty Code | BRSTRDCPRTYCDE_${VAR_RANDOM} |
      | Generic FINS ID             | GENFINSID_${VAR_RANDOM}      |
      | Issuer Ticker               | ISSTICKER_${VAR_RANDOM}      |
      | Fins Mnemonic               | FINSMNEM_${VAR_RANDOM}       |
      | Reuters Organisation Id     | RTORGID_${VAR_RANDOM}        |

    And I update Institution with following details
      | Country Of Domicile        | Angola                |
      | Institution Status         | Acquired              |
      | Preferred Identifier Name  | Reuters Org Level ID  |
      | Preferred Identifier Value | RTORGID_${VAR_RANDOM} |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "Test_Institution2_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "Test_Institution2_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I open Institution "Test_Institution2_${VAR_RANDOM}" record

    Then I expect Institution details are updated as below
      | Country Of Domicile        | Angola                |
      | Institution Status         | Acquired              |
      | Preferred Identifier Name  | Reuters Org Level ID  |
      | Preferred Identifier Value | RTORGID_${VAR_RANDOM} |

  Scenario: Close browsers
    Then I close all opened web browsers
