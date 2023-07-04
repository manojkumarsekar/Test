#https://jira.pruconnect.net/browse/EISDEV-6416
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND#businessRequirements-508441805
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction

#EISDEV-7172 Changes --START--
#For IDX On market transaction, please include - symbol if BRS provides values in negative for the TRD_INTEREST attribute
#Hiport Attribute name: XN_NATIVE_INCOME.0001
#BRS Mapping:TRD_INTEREST
#Sections impacted :FI Mapping & DS Mapping
#Files Impacted: TFTXNFI.qqq,TFCASH.qqq,TMBTXNFI.qqq,TMBCASH.qqq
# EISDEV-7172 Changes --END--

#EISDEV-7492 Changes --START--
#For IDX On market transaction, please remove negative symbol if BRS provides values in negative for the TRD_INTEREST attribute, It is rollback of 7172
#Hiport Attribute name: XN_NATIVE_INCOME.0001
#BRS Mapping:TRD_INTEREST
#Sections impacted :FI Mapping & DS Mapping
#Files Impacted: TFTXNFI.qqq,TFCASH.qqq,TMBTXNFI.qqq,TMBCASH.qqq
# EISDEV-7492 Changes --END--

@gc_interface_trades @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities @gc_interface_issuer @gc_interface_counterparty
@dmp_regression_integrationtest
@eisdev_6416 @004_tfund_onmarket_publish @dmp_thailand_hiport @dmp_thailand @eisdev_6937 @eisdev_7172 @eisdev_7492
Feature: Publish the trade file in the Hiport format for TFUND

  This feature will test the below scenarios
  1. Load Issuer file received as part of the trade nugget
  2. Load the Counterparty file received as part of the trade nugget
  3. Load the security file received as part of the trade nugget
  4. Load the portfolio file received as part of the trade nugget
  5. Load the transaction file received as part of the trade nugget
  6. Publish the HiPort file
  7. Recon the published file against the expected file

  Scenario: TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget" to variable "testdata.path"

    #Portfolio Setup Files
    And I assign "Portfolio_Setup_Prerequisite.xlsx" to variable "PORTFOLIO_SETUP_FILE"

    #Issuer Files
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Issuer_Template.xml" to variable "ISSUER_TEMPLATE"
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Issuer_Prerequisite.xml" to variable "ISSUER_FILE"

    #Counterparty Files
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Broker_Template.xml" to variable "COUNTERPARTY_TEMPLATE"
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Broker_Prerequisite.xml" to variable "COUNTERPARTY_FILE"

    #Security Files
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Security_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Security_Prerequisite.xml" to variable "SECURITY_FILE"

    #Portfolio Files
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Portfolio_Template.xml" to variable "PORTFOLIO_TEMPLATE"
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Portfolio_Prerequisite.xml" to variable "PORTFOLIO_FILE"

    #Transaction Files
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Transaction_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "004_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Transaction_Prerequisite.xml" to variable "TRANSACTION_FILE"

    #Publish files
    And I assign "004_Trade_Nugget_TH_TFUND_Transaction_Template_Publish" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "004_Trade_Nugget_TH_TFUND_Transaction_Actual_Publish" to variable "PUBLISH_FILE_ACTUAL"
    And I assign "004_Trade_Nugget_TH_TFUND_Transaction_Expected_Publish" to variable "PUBLISH_FILE_EXPECTED"

    #Generate Sys Date and assign to variable
    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "ss" and assign to variable "VAR_RANDOM"

    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "M/dd/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "M/dd/YYYY" to destination format "YYMMdd" and assign to "CURRENT_DATE"

    #Trigger publish to clear any unpublished files
  Scenario Outline: TC2: Publish any unpublished files to clear the log
    Given I remove below files with pattern in the host "dmp.ssh.outbound" from folder "<PUBLISHING_DIRECTORY>" if exists:
      | *.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | DummyFile_<AssetClass>.qqq    |
      | SUBSCRIPTION_NAME           | <AssetClassPublishingProfile> |
      | FOOTER_COUNT                | 1                             |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I remove below files with pattern in the host "dmp.ssh.outbound" from folder "<PUBLISHING_DIRECTORY>" if exists:
      | DummyFile_* |

    Examples:
      | AssetClass | AssetClassPublishingProfile             | PUBLISHING_DIRECTORY       |
      | Equity     | EITH_DMP_TO_TFUND_HIPORT_TRADE_EQ_SUB   | /dmp/out/thailand/intraday |
      | Fund       | EITH_DMP_TO_TFUND_HIPORT_TRADE_FUND_SUB | /dmp/out/thailand/intraday |
      | Bond       | EITH_DMP_TO_TFUND_HIPORT_TRADE_FI_SUB   | /dmp/out/thailand/intraday |
      | Cash       | EITH_DMP_TO_TFUND_HIPORT_TRADE_CASH_SUB | /dmp/out/thailand/intraday |

    #Create Portfolio
  Scenario: TC3: Create the test portfolio and insert portofolio into Portgroup

    When I process "${testdata.path}/Inbound/TFUND/testdata/${PORTFOLIO_SETUP_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_SETUP_FILE}              |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I execute below query to "Create participants for TFUND- TFB-AG group"
    """
    ${testdata.path}/Outbound/TFUND/sql/InsertIntoACGPTable.sql
    """

    #Load Issuer files
  Scenario: TC4: Load the Issuer file in the trade nugget

    Given I create input file "${ISSUER_FILE}" using template "${ISSUER_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${ISSUER_FILE}" file with below parameters
      | FILE_PATTERN  | ${ISSUER_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER |
      | BUSINESS_FEED |                   |

    Then I expect workflow is processed in DMP with success record count as "8"

    #Load Counterparty files
  Scenario: TC5: Load the Broker file in the trade nugget

    Given I create input file "${COUNTERPARTY_FILE}" using template "${COUNTERPARTY_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${COUNTERPARTY_FILE}" file with below parameters
      | FILE_PATTERN  | ${COUNTERPARTY_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Load Security files
  Scenario: TC6: Load the Security file in the trade nugget

    Given I create input file "${SECURITY_FILE}" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${SECURITY_FILE}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "10"

    #Load Portfolio files
  Scenario: TC7: Load the Portfolio file in the trade nugget

    Given I create input file "${PORTFOLIO_FILE}" using template "${PORTFOLIO_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${PORTFOLIO_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Load Transaction files
  Scenario: TC8: Load the Transaction file in the trade nugget

    Given I create input file "${TRANSACTION_FILE}" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/Outbound/TFUND/inputfiles"

    When I process "${testdata.path}/Outbound/TFUND/inputfiles/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "20"

    #Publish the trade file in Hiport format
  Scenario Outline: TC9: Publish the trade file in HiPort format for each asset class and compare with expected

    Given I remove below files with pattern in the host "dmp.ssh.outbound" from folder "<PUBLISHING_DIRECTORY>" if exists:
      | ${PUBLISH_FILE_ACTUAL}* |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL}_<AssetClass>.qqq |
      | SUBSCRIPTION_NAME           | <AssetClassPublishingProfile>           |
      | FOOTER_COUNT                | 1                                       |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                    |


    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "<PUBLISHING_DIRECTORY>" after processing:
      | ${PUBLISH_FILE_ACTUAL}_<AssetClass>_${DYNAMIC_FILE_DATE}_1.qqq |

    Then I copy files below from remote folder "<PUBLISHING_DIRECTORY>" on host "dmp.ssh.outbound" into local folder "${testdata.path}/Outbound/TFUND/outfiles/testdata":
      | ${PUBLISH_FILE_ACTUAL}_<AssetClass>_${DYNAMIC_FILE_DATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.outbound" from folder "<PUBLISHING_DIRECTORY>" if exists:
      | ${PUBLISH_FILE_ACTUAL}* |

    #Recon the published file against the expected file
    Given I create input file "${PUBLISH_FILE_EXPECTED}_<AssetClass>.qqq" using template "${PUBLISH_FILE_TEMPLATE}_<AssetClass>.qqq" from location "${testdata.path}/Outbound/TFUND/outfiles"

    Then I expect file "${testdata.path}/Outbound/TFUND/outfiles/testdata/${PUBLISH_FILE_ACTUAL}_<AssetClass>_${DYNAMIC_FILE_DATE}_1.qqq" should have below columns
      | IDXITRI-H  |
      | THB        |
      | <Filename> |
      | qqq        |

    And I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/Outbound/TFUND/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_<AssetClass>.qqq                      |
      | File2 | ${testdata.path}/Outbound/TFUND/outfiles/testdata/${PUBLISH_FILE_ACTUAL}_<AssetClass>_${DYNAMIC_FILE_DATE}_1.qqq |

    Examples:
      | AssetClass | AssetClassPublishingProfile             | PUBLISHING_DIRECTORY       | Filename |
      | Equity     | EITH_DMP_TO_TFUND_HIPORT_TRADE_EQ_SUB   | /dmp/out/thailand/intraday | TFTXNEQ  |
      | Fund       | EITH_DMP_TO_TFUND_HIPORT_TRADE_FUND_SUB | /dmp/out/thailand/intraday | TFTXNFD  |
      | Bond       | EITH_DMP_TO_TFUND_HIPORT_TRADE_FI_SUB   | /dmp/out/thailand/intraday | TFTXNFI  |
      | Cash       | EITH_DMP_TO_TFUND_HIPORT_TRADE_CASH_SUB | /dmp/out/thailand/intraday | TFCASH   |