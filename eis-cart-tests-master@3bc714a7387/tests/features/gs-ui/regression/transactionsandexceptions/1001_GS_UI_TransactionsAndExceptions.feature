@web @gs_ui_regression @gc_ui_transaction_and_exceptions
Feature: Transaction and Exceptions

  This feature file can be used to check the Transactions and Exceptions functionality over UI.

  Scenario: Load File10 to generate exceptions

    Given I assign "tests/test-data/gs-ui/top10/transactionsandexceptions/file10" to variable "testdata.path"
    And I assign "File10.xml" to variable "LOAD_FILE_NAME"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | File10.xml              |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

  Scenario: Resubmit Transactions And Exceptions

    Given I login to golden source UI with "task_assignee" role
    When I search for the Transactions And Exceptions with following search criteria
      | Notification Status | OPEN                                                                                                                                                                                                  |
      | Default Severity    | ERROR                                                                                                                                                                                                 |
      | Details             | The following field(s)and value(s)(stored in the Market/Issue Characteristics table) being supplied by BRS  cannot be validated against the list in the Internal Domain table: Trading Currency = ABC |
      | Source Id           | GS_GC                                                                                                                                                                                                 |

    And I capture Notification Occurrence Count into "NC_COUNT"
    And I Resubmit the Transactions And Exceptions
    Then I expect Notification Occurrence Count should be "${NC_COUNT}+1"

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: Close Transactions And Exceptions

    Given I login to golden source UI with "task_assignee" role
    When I search for the Transactions And Exceptions with following search criteria
      | Notification Status | OPEN                                                                                                                                                                                                  |
      | Default Severity    | ERROR                                                                                                                                                                                                 |
      | Details             | The following field(s)and value(s)(stored in the Market/Issue Characteristics table) being supplied by BRS  cannot be validated against the list in the Internal Domain table: Trading Currency = ABC |
      | Source Id           | GS_GC                                                                                                                                                                                                 |

    When I Close Transactions And Exceptions
    Then I expect Transactions And Exceptions is closed

  Scenario: Close browsers
    Then I close all opened web browsers
