@tom_3696 @web @0001_EIS_UI_TaiwanFinancialInstitution_Broker @ignore @tom_3982
Feature: Create Financial Institution for Broker details
  This feature file can be used to check the Financial Institution create functionality over UI.
  This handles both the maker checker event require to create Financial Institution.

  Scenario: Create New Financial Institution for Broker details

    Given I login to golden source UI with "task_assignee" role
    When I add Institution Name for the Financial Institution as below
      | Institution Name | Neuberger Berman Taiwan (SITE) Limited |

    And I add Description details for the Financial Institution as below
      | Institution Name              | Brown Brother Harriman HK Ltd / cc. Neuberger Berman Taiwan |
      | Institution Description Usage | Taiwan Alternate Name                                       |


    And I add LBU Identifiers Details for the Financial Institution as below
      | Taiwan BRS Broker Code    | NBT-TW |
      | Taiwan BRS Broker Code    | NBT-TW |
      | Taiwan Broker Agent ID    |        |
      | Taiwan Broker Register ID |        |


    And I add Taiwan Broker Details details for the Financial Institution as below
      | Taiwan Agent Code       | AGT  |
      | CIS Order SWIFT Enabled | No   |
      | Footer Information      | Test |

    And I add Address details for the Financial Institution as below
      | Address Type | Primary |

    # Glue Code (+) - Click on the link for Electronic Address and then key in Telephone Number , Fax Phone Number and Attention Text

    And I save the Financial Institution details
    Then I expect the Financial Institution record is moved to My WorkList for approval

    When I relogin to golden source UI with "task_authorizer" role
    And I approve Financial Institution record

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Financial Institution is created

  Scenario: Close browsers
    Then I close all opened web browsers
