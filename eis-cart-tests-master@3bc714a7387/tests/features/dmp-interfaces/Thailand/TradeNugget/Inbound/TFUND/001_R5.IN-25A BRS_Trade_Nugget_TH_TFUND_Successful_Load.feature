#https://jira.pruconnect.net/browse/EISDEV-6416
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND#businessRequirements-508441805
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction

@gc_interface_portfolios @gc_interface_issuer @gc_interface_counterparty @gc_interface_securities @gc_interface_transactions
@dmp_regression_integrationtest
@eisdev_6416 @001_tfund_onmarket_load @dmp_thailand_hiport @dmp_thailand
Feature: Load the trade nugget file and all associated files

  This feature will test the below scenarios
  1. Load Issuer file received as part of the trade nugget
  2. Load the Counterparty file received as part of the trade nugget
  3. Load the security file received as part of the trade nugget
  4. Load the portfolio file received as part of the trade nugget
  5. Load the transaction file received as part of the trade nugget
  6. Verify the data is loaded into EXTR table

  Scenario: TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget" to variable "testdata.path"

    #Portfolio Setup Files
    And I assign "Portfolio_Setup_Prerequisite.xlsx" to variable "PORTFOLIO_SETUP_FILE"

    #Issuer Files
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Issuer_Template.xml" to variable "ISSUER_TEMPLATE"
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Issuer_Prerequisite.xml" to variable "ISSUER_FILE"

    #Counterparty Files
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Broker_Template.xml" to variable "COUNTERPARTY_TEMPLATE"
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Broker_Prerequisite.xml" to variable "COUNTERPARTY_FILE"

    #Security Files
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Security_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Security_Prerequisite.xml" to variable "SECURITY_FILE"

    #Portfolio Files
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Portfolio_Template.xml" to variable "PORTFOLIO_TEMPLATE"
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Portfolio_Prerequisite.xml" to variable "PORTFOLIO_FILE"

    #Transaction Files
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Transaction_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_TFUND_Transaction_Prerequisite.xml" to variable "TRANSACTION_FILE"

    #Generate Sys Date and assign to variable
    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "ss" and assign to variable "VAR_RANDOM"

    #Create Portfolio
  Scenario: TC2: Create the test portfolio and add the portfolio into TFB-AG group

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
  Scenario: TC3: Load the Issuer file in the trade nugget

    Given I create input file "${ISSUER_FILE}" using template "${ISSUER_TEMPLATE}" from location "${testdata.path}/Inbound/TFUND"

    When I process "${testdata.path}/Inbound/TFUND/testdata/${ISSUER_FILE}" file with below parameters
      | FILE_PATTERN  | ${ISSUER_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER |
      | BUSINESS_FEED |                   |

    Then I expect workflow is processed in DMP with total record count as "3"

    #Load Counterparty files
  Scenario: TC4: Load the Broker file in the trade nugget

    Given I create input file "${COUNTERPARTY_FILE}" using template "${COUNTERPARTY_TEMPLATE}" from location "${testdata.path}/Inbound/TFUND"

    When I process "${testdata.path}/Inbound/TFUND/testdata/${COUNTERPARTY_FILE}" file with below parameters
      | FILE_PATTERN  | ${COUNTERPARTY_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Load Security files
  Scenario: TC5: Load the Security file in the trade nugget

    Given I create input file "${SECURITY_FILE}" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/Inbound/TFUND"

    When I process "${testdata.path}/Inbound/TFUND/testdata/${SECURITY_FILE}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "3"

    #Load Portfolio files
  Scenario: TC6: Load the Portfolio file in the trade nugget

    Given I create input file "${PORTFOLIO_FILE}" using template "${PORTFOLIO_TEMPLATE}" from location "${testdata.path}/Inbound/TFUND"

    When I process "${testdata.path}/Inbound/TFUND/testdata/${PORTFOLIO_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    #Load Transaction files
  Scenario: TC7: Load the Transaction file in the trade nugget

    Given I create input file "${TRANSACTION_FILE}" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/Inbound/TFUND"

    When I process "${testdata.path}/Inbound/TFUND/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "3"

    #Verify the transaction count in EXTR table
  Scenario Outline: TC8: Verify the trade count in EXTR table for <AssetClass> security

    And I expect value of column "TRD_COUNT" in the below SQL query equals to "1":
  """
    SELECT COUNT(*) AS TRD_COUNT
    FROM FT_T_EXTR WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='TST-TF10')
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '<INSTR_ID>')
    AND TRUNC(TRD_DTE) = TRUNC(SYSDATE)
    AND TRD_ID = '<TRADE_ID>'
    AND TRD_DTE IS NOT NULL
  """

    Examples:
      | AssetClass | INSTR_ID  | TRADE_ID                |
      | Equity     | BRT8GK778 | 16404-TRD4${VAR_RANDOM} |
      | Fund       | SB9HL5X67 | 16404-TRD5${VAR_RANDOM} |
      | Bond       | BPM06MBJ2 | 16404-TRD6${VAR_RANDOM} |

    #Verify the Hiport ID in ETCM table
  Scenario Outline: TC9: Verify the Hiport ID in ETCM table for <AssetClass> security

    And I expect value of column "ID_COUNT" in the below SQL query equals to "<COUNT>":
  """
    SELECT COUNT(*) AS ID_COUNT
    FROM FT_T_ETCM WHERE EXEC_TRD_ID IN
     (SELECT EXEC_TRD_ID FROM FT_T_EXTR WHERE TRD_ID ='<TRADE_ID>')
    AND CMNT_REAS_TYP = 'HIPORTSECID'
    AND CMNT_TXT='<HIPORTID>'
  """

    Examples:
      | AssetClass | HIPORTID | TRADE_ID                | COUNT |
      | Equity     | AOT      | 16404-TRD4${VAR_RANDOM} | 1     |
      | Fund       | BTSGIF   | 16404-TRD5${VAR_RANDOM} | 1     |
      | Bond       | BANP225A | 16404-TRD6${VAR_RANDOM} | 1     |
