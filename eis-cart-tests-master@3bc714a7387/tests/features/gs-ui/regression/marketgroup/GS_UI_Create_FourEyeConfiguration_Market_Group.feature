#eisdev_5279 - Added new UI module Market group for test automation with maker and checker

@web @gs_ui_regression @gc_ui_market_group @eisdev_5279
Feature: Create New Market group
  This feature file can be used to check the Market Group create functionality over UI.
  This handles both the maker checker event require to create Market Group.

  Scenario: Create New Market group
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    Then I add Market Details for the MarketGroup as below
      | Market Group Name  | MarketDummyGroup_${VAR_RANDOM} |
      | Group Description  | MarketDummyGroup               |
      | Group Purpose Type | Universe                       |
      | Group Created On   | 03022020                       |

    Then I add Market Group Participant for the MarketGroup as below
      | Exchange Name            | NASDAQ OMX PSX   |
      | Participant Description  | MarketDummyGroup |
      | Participant Purpose Type | Maximum rate     |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "MarketDummyGroup_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    When I update Market Group "MarketDummyGroup_${VAR_RANDOM}" with below details
      | Group Purpose Type       | BROKERS |
      | Participant Purpose Type | Member  |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "MarketDummyGroup_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Market Group "MarketDummyGroup_${VAR_RANDOM}" is updated as below
      | Group Purpose Type       | Brokers |
      | Participant Purpose Type | Member  |

