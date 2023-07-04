#https://jira.intranet.asia/browse/TOM-3701

@web @gs_ui_instrument_group @tom_3701
Feature: Verify a field in the Instrument group screen
  This feature file is to test the presence of ISIN field in Instrument Group screen

  Scenario: Verify if ISIN field is present on Instrument Group screen

    Given I login to golden source UI with "task_assignee" role
    And I navigate "Security Master : Instrument Group" screen
    And I click "+" in "Group Participants Details" section
    Then I should see a field "ISIN" in "Group Participants Details" section
    And I select Instrument name "GUANGXI LIUZHOU PHARMACEUTICAL ORD SHS A"
    Then I expect ISIN is populated with "CNE100001VR3"

  Scenario: Close browsers
    Then I close all opened web browsers


