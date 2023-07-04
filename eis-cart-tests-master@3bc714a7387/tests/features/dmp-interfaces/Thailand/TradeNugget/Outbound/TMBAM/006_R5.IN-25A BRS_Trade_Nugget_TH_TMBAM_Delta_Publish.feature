#https://jira.pruconnect.net/browse/EISDEV-6416
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND#businessRequirements-508441805
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction

@gc_interface_trades @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6416 @006_tmbam_onmarket_publish @dmp_thailand_hiport @dmp_thailand @tmbam_hiport @eisdev_6877
Feature: Publish only the delta trades to Hiport

  This feature will test the below scenarios
  1. Load a file with a trade
  2. Publish the trade
  3. Load a transaction file with below trades
  Same trade published earlier with no changes
  A new trade
  4. Trigger trade publish in Hiport format
  5. Verify only the new trade is published

  Scenario: TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget" to variable "testdata.path"

    #Portfolio Setup Files
    And I assign "Portfolio_Setup_Prerequisite.xlsx" to variable "PORTFOLIO_SETUP_FILE"

    #Security Files
    And I assign "005_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Security_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "005_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Security_Prerequisite.xml" to variable "SECURITY_FILE"

    #Portfolio Files
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Portfolio_Template.xml" to variable "PORTFOLIO_TEMPLATE"
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Portfolio_Prerequisite.xml" to variable "PORTFOLIO_FILE"

    #Transaction Files as prerequisite
    And I assign "006_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Transaction_Template_01.xml" to variable "TRANSACTION_TEMPLATE_01"
    And I assign "006_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Transaction_Prerequisite_01.xml" to variable "TRANSACTION_FILE_01"

    #Transaction Files with test data
    And I assign "006_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Transaction_Template_02.xml" to variable "TRANSACTION_TEMPLATE_02"
    And I assign "006_R5.IN-25A BRS_Trade_Nugget_TH_TMBAM_Transaction_Prerequisite_02.xml" to variable "TRANSACTION_FILE_02"

    #Publish files & directory
    And I assign "006_Trade_Nugget_TH_TMBAM_Transaction_Template_Publish_02.qqq" to variable "PUBLISH_FILE_TEMPLATE_02"
    And I assign "006_Trade_Nugget_TH_TMBAM_Transaction_Expected_Publish_02.qqq" to variable "PUBLISH_FILE_EXPECTED_02"
    And I assign "006_Trade_Nugget_TH_TMBAM_Transaction_Actual_Publish_01" to variable "PUBLISH_FILE_ACTUAL_01"
    And I assign "006_Trade_Nugget_TH_TMBAM_Transaction_Actual_Publish_02" to variable "PUBLISH_FILE_ACTUAL_02"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"


    #Generate Sys Date and assign to variable
    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "ss" and assign to variable "VAR_RANDOM"

    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "M/dd/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "M/dd/YYYY" to destination format "YYMMdd" and assign to "CURRENT_DATE"

    #Trigger publish to clear any unpublished files
  Scenario: TC2: Publish any unpublished files to clear the log

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | DummyFile.qqq                           |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_FUND_SUB |
      | FOOTER_COUNT                | 1                                       |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                    |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | DummyFile_* |

    #Create Portfolio
  Scenario: TC3: Create the test portfolio and insert portofolio into Portgroup

    When I process "${testdata.path}/Inbound/TMBAM/testdata/${PORTFOLIO_SETUP_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_SETUP_FILE}              |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I execute below query to "Create participants for TMBAM- TMB-AG group"
    """
    ${testdata.path}/Outbound/TMBAM/sql/InsertIntoACGPTable.sql
    """

    #Load Security files
  Scenario: TC4: Load the Security file in the trade nugget

    Given I create input file "${SECURITY_FILE}" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/Outbound/TMBAM/inputfiles"

    When I process "${testdata.path}/Outbound/TMBAM/inputfiles/testdata/${SECURITY_FILE}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "1"

    #Load Portfolio files
  Scenario: TC5: Load the Portfolio file to update BRS Fund ID

    Given I create input file "${PORTFOLIO_FILE}" using template "${PORTFOLIO_TEMPLATE}" from location "${testdata.path}/Outbound/TMBAM/inputfiles"

    When I process "${testdata.path}/Outbound/TMBAM/inputfiles/testdata/${PORTFOLIO_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Load Transaction files for the prerequisite trade
  Scenario: TC6: Load the prerequisite trades into DMP

    Given I create input file "${TRANSACTION_FILE_01}" using template "${TRANSACTION_TEMPLATE_01}" from location "${testdata.path}/Outbound/TMBAM/inputfiles"

    When I process "${testdata.path}/Outbound/TMBAM/inputfiles/testdata/${TRANSACTION_FILE_01}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE_01}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Publish the trade file in Hiport format
  Scenario: TC7: Publish the trade file in HiPort format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL_01}*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL_01}.qqq           |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_FUND_SUB |
      | FOOTER_COUNT                | 1                                       |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                    |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL_01}*.qqq |

    #Load Transaction files
  Scenario: TC8: Load the Transaction file with data combination

    Given I create input file "${TRANSACTION_FILE_02}" using template "${TRANSACTION_TEMPLATE_02}" from location "${testdata.path}/Outbound/TMBAM/inputfiles"

    When I process "${testdata.path}/Outbound/TMBAM/inputfiles/testdata/${TRANSACTION_FILE_02}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE_02}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "2"

    #Publish the trade file in Hiport format
  Scenario: TC9: Publish the trade file in HiPort format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL_02}*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL_02}.qqq           |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_FUND_SUB |
      | FOOTER_COUNT                | 1                                       |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                    |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL_02}*.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/Outbound/TMBAM/outfiles/testdata":
      | ${PUBLISH_FILE_ACTUAL_02}*.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL_02}* |

  Scenario: TC10: Verify only the delta trade is published

    Given I create input file "${PUBLISH_FILE_EXPECTED_02}" using template "${PUBLISH_FILE_TEMPLATE_02}" from location "${testdata.path}/Outbound/TMBAM/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/Outbound/TMBAM/outfiles/testdata/${PUBLISH_FILE_EXPECTED_02}                          |
      | File2 | ${testdata.path}/Outbound/TMBAM/outfiles/testdata/${PUBLISH_FILE_ACTUAL_02}_${DYNAMIC_FILE_DATE}_1.qqq |