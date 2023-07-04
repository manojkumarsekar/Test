#https://jira.pruconnect.net/browse/EISDEV-6114

@eisdev_6114 @web @ignore @web_pending
Feature: This feature is to test Research Report screen
  Open Research Report screen through link menu Eastspring --> ResearchReport
  Search for a Research Report using Research ID/Link
  Verify contents on detail screen and verify if the screen is readonly

  Scenario: Verify if search Screen and detail screen is rendering

    Given I login to golden source UI with "task_assignee" role
    And I navigate "Eastspring : Research Report" screen
    Then I should see a field "Research ID/Link"
    Then I search for a Research Report as below
      | Research ID/Link | https://eastspring.blackrock.com/aladdinresearch/index.html#/link/28661 |

    Then I should see values as below
      | Research ID/Link  | https://eastspring.blackrock.com/aladdinresearch/index.html#/link/28661 |
      | Research Category | TW GFI Buy Sell                                                         |
      | Research Status   | TW Research Expired                                                     |

    Then I should see if Save is disabled

  Scenario: Close browsers
    Then I close all opened web browsers