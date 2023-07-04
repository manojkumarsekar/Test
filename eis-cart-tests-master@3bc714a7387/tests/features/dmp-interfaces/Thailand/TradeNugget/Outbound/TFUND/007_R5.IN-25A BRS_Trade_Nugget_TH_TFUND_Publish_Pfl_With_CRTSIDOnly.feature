#https://jira.pruconnect.net/browse/EISDEV-6416
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND#businessRequirements-508441805
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction

@gc_interface_trades @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6416 @007_tfund_onmarket_publish @dmp_thailand_hiport @dmp_thailand @eisdev_6937
Feature: Publish trade to Hiport for a portfolio with CRTSID only

  This feature will test the below scenarios
  1. Create a portfolio with CRTS ID and no Thai ID
  2. Load trades for the above portfolio
  3. Publish the trade file and verify CRTS ID is published

  Scenario: TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget" to variable "testdata.path"

    #Portfolio Setup Files
    And I assign "007_Portfolio_Setup_Prerequisite.xlsx" to variable "PORTFOLIO_SETUP_FILE"

    #Security Files
    And I assign "007_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Security_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "007_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Security_Prerequisite.xml" to variable "SECURITY_FILE"

    #Portfolio Files
    And I assign "007_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Portfolio_Template.xml" to variable "PORTFOLIO_TEMPLATE"
    And I assign "007_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Portfolio_Prerequisite.xml" to variable "PORTFOLIO_FILE"

    #Transaction Files
    And I assign "007_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Transaction_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "007_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Transaction_Prerequisite.xml" to variable "TRANSACTION_FILE"

    #Publish files & directory
    And I assign "007_Trade_Nugget_TH_TFUND_Transaction_Template_Publish.qqq" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "007_Trade_Nugget_TH_TFUND_Transaction_Expected_Publish.qqq" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "007_Trade_Nugget_TH_TFUND_Transaction_Actual_Publish" to variable "PUBLISH_FILE_ACTUAL"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"

    #Generate Sys Date and assign to variable
    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "ss" and assign to variable "VAR_RANDOM"

    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "M/dd/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "M/dd/YYYY" to destination format "YYMMdd" and assign to "CURRENT_DATE"

    #Trigger publish to clear any unpublished files
  Scenario: TC2: Publish any unpublished files to clear the log

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | DummyFile.qqq                         |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_EQ_SUB |
      | FOOTER_COUNT                | 1                                     |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                  |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | DummyFile_* |

    #Create Portfolio
  Scenario: TC3: Create the test portfolio and insert portofolio into Portgroup

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${PORTFOLIO_SETUP_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_SETUP_FILE}              |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I execute below query to "Create participants for TFUND- TFB-AG group"
    """
    ${testdata.path}/Outbound/TFUND/sql/InsertIntoACGPTable.sql
    """

    #Load Security files
  Scenario: TC4: Load the Security file in the trade nugget

    Given I create input file "${SECURITY_FILE}" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${SECURITY_FILE}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Load Portfolio files
  Scenario: TC5: Load the Portfolio file to update BRS Fund ID

    Given I create input file "${PORTFOLIO_FILE}" using template "${PORTFOLIO_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${PORTFOLIO_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with success record count as "1"

     #Load Transaction files
  Scenario: TC6: Load the Transaction file

    Given I create input file "${TRANSACTION_FILE}" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Publish the trade file in Hiport format
  Scenario: TC7: Publish the trade file in HiPort format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL}.qqq            |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_EQ_SUB |
      | FOOTER_COUNT                | 1                                     |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                  |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/Outbound/TFUND/outfiles/testdata":
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}* |

  Scenario: TC8: Verify the published trade has CRTS ID

    Given I create input file "${PUBLISH_FILE_EXPECTED}" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/Outbound/TFUND/outfiles/testdata/${PUBLISH_FILE_EXPECTED}                          |
      | File2 | ${testdata.path}/Outbound/TFUND/outfiles/testdata/${PUBLISH_FILE_ACTUAL}_${DYNAMIC_FILE_DATE}_1.qqq |