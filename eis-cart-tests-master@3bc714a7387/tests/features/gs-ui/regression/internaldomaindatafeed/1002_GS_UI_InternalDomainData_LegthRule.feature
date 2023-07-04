@web @gs_ui_regression @tom_3515 @eisdev_6754 @gc_ui_internaldomain_datafeed
Feature: Update Internal Domian For Data Feed

  Scenario: Test Validation

    Given I login to golden source UI with "administrators" role
    When I select from GS menu "Generic Setup::Internal Domain For Data Field"

    #Its has Max of 4 characters limit
    And I enter the text "00000055" into web element "${gs.web.table.filter1.input}" followed by "ENTER" key
    And I pause for 1 seconds

    And I enter the text "COST1" into web element "${gs.web.fld.DomainValue}"

    And I save changes
    And I pause for 1 seconds

    Then I expect there is 1 validation error on screen
    And I expect below validation error messages on screen
      | GSO / Field        | Domain Values                                                                          |
      | Severity           | ERROR                                                                                  |
      | Validation Message | Domain Value entered should be equal to less than the length of the destination field. |
    Then I close active GS tab

    When I select from GS menu "Generic Setup::Internal Domain For Data Field Class"

    #Its has Max of 4 characters limit
    And I enter the text "ACCTGID" into web element "${gs.web.table.filter1.input}" followed by "ENTER" key
    And I pause for 1 seconds

    And I click the web element "${gs.web.AddDetails}"
    And I pause for 1 seconds

    And I enter the text "DUMMY" into web element "${gs.web.fcd.DomainValue}"

    And I save changes
    And I pause for 1 seconds

    Then I expect there is 3 validation error on screen
    And I expect below validation error messages on screen
      | GSO / Field        | Domain Values                                                                          |
      | Severity           | ERROR                                                                                  |
      | Validation Message | Domain Value entered should be equal to less than the length of the destination field. |
    Then I close active GS tab

  Scenario: Close
    Then I close all opened web browsers
