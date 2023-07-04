@web @ignore @web_pending
@gc_ui_financial_institution @gc_ui_worklist

Feature: Create and update Financial Institution Group
  This feature file can be used to check the Financial Institution Group update functionality over UI.
  This handles both the maker checker event require to update Financial Institution Group/Financial Institution Participants.

  Scenario: Update Financial Institution Group Participants
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "TST_FINS_GRP_${VAR_RANDOM}" to variable "FINS_GRP_NME"

    When I enter below Financial Institution Group for new Financial Institution Group
      | Group Name        | ${FINS_GRP_NME} |
      | Group Description | TST_IDESC       |
      | Effective Date    | T               |
      | Group Purpose     | Universe        |

    And I add below Group Member details
      | Institution Name        | SHANGHAI DAIMAY AUTOMOTIVE INTERIOR CO LTD |
      | Participant Purpose     | Member                                     |
      | Effective Date          | T                                          |
      | Participant Description | FA AIF Participant                         |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${FINS_GRP_NME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${FINS_GRP_NME}"

    And I relogin to golden source UI with "task_assignee" role

    And I open existing Issue "${FINS_GRP_NME}"

    And I add below Group Member details
      | Institution Name        | XDC INDUSTRIES SHENZHEN LTD |
      | Participant Purpose     | Member                      |
      | Effective Date          | T                           |
      | Participant Description | FA AIF Participant          |

    And I save the valid data
    Then I expect a record in My WorkList with entity name "${FINS_GRP_NME}"

    And I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${FINS_GRP_NME}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect below Group Member details updated for the Financial Institution Group "${FINS_GRP_NME}"
      | Institution Name        | XDC INDUSTRIES SHENZHEN LTD |
      | Participant Purpose     | Member                      |
      | Effective Date          | T                           |
      | Participant Description | FA AIF Participant          |

  Scenario: Close browsers
    Then I close all opened web browsers
