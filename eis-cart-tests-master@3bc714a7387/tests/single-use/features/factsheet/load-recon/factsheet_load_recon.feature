#https://jira.pruconnect.net/browse/EISAPPDEV-5
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=60792291

# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 06/08/2019      TOM-5032    First Version
# =====================================================================
   # Business Need : As part of factsheets tactical project, reconcilliation
   # of load of custodian files in Azure Vs Eagle database to be performed.
# =====================================================================


@ignore_hooks @factsheet_load_recon
Feature: Factsheet data load recon

  Scenario: Set up Database Details

    Given I assign "jdbc_a" to variable "factsheet.eagle.type"
    Given I assign "jdbc:oracle:thin:@10.163.153.34:1525/EGLPRD" to variable "factsheet.eagle.jdbc.url"
    Given I assign "oracle.jdbc.driver.OracleDriver" to variable "factsheet.eagle.jdbc.class"
    Given I assign "eglsupp" to variable "factsheet.eagle.jdbc.user"
    Given I assign "eglsupp" to variable "factsheet.eagle.jdbc.pass"
    Given I assign "Factsheet Eagle Database PROD" to variable "factsheet.eagle.jdbc.description"

    Given I assign "jdbc_a" to variable "factsheet.azure.type"
    Given I assign "jdbc:oracle:thin:@asgesivluora001.pru.intranet.asia:1527/FACTSHEET" to variable "factsheet.azure.jdbc.url"
    Given I assign "oracle.jdbc.driver.OracleDriver" to variable "factsheet.azure.jdbc.class"
    Given I assign "factsheet" to variable "factsheet.azure.jdbc.user"
    Given I assign "Fact1234" to variable "factsheet.azure.jdbc.pass"
    Given I assign "Factsheet Azure Database DEV" to variable "factsheet.azure.jdbc.description"

    Given I assign "tests/features/factsheet/load-recon" to variable "testdata.path"

  Scenario Outline: Recon for Table <table>

    And I assign "${testdata.path}/eagle_<table>.csv" to variable "EAGLE_FILE"
    And I assign "${testdata.path}/azure_<table>.csv" to variable "AZURE_FILE"
    And I assign "${testdata.path}/exceptions_<table>.csv" to variable "EXCEP_FILE"

    Given I set the database connection to configuration "factsheet.eagle"
    And I export below sql query results to CSV file "${EAGLE_FILE}"
    """
    SELECT <columns> FROM EGLPRU.<table>
    """

    Given I set the database connection to configuration "factsheet.azure"

    And I export below sql query results to CSV file "${AZURE_FILE}"
    """
    SELECT <columns> FROM <table>
    """

    Then I expect reconciliation between generated CSV file "${AZURE_FILE}" and reference CSV file "${EAGLE_FILE}" should be successful and exceptions to be written to "${EXCEP_FILE}" file

    Examples: Queries
      | table                 | columns                        |
      | KRTS_GBLFUND_MNG_LOAD | MNG_NAME, WEIGHTS, SOURCE_NAME |
      | FSHEET_OVERLAY_DETAIL  | FUNDNAME, FUNDCODE, ALLOC_TYPE, INIT_VAL, MAPPED_VAL                                                                                                                                                                                                                                     |
      | KRTS_HSBC_LOAD         | C_FUND, L_FUND, C_CCY_PTF, TYPE_OF_SECURITIES, C_ID_ISIN, C_ID_SEDOL, L_SEC_NAME, ECONOMIC, COUNTRY, RATING, AGENCY_RATING, PERCENT_AGE, FEED_CODE, AUM                                                                                                                                  |
      | PPMA_KURTOSYS          | ISIN, CUSIP, CONCATE_DESC, MERILL_IND_L2, FITCH_RATING, MOODY_RATING, SNP_RATING, PORT_NAME, TICKER, MATURITY_DATE                                                                                                                                                                       |
      | RDM_KURTOSYS           | SECURITY_ALIAS, ISSUE_NAME, SECURITY_TYPE, SEDOL, CUSIP, TICKER, ISIN, MATURITY_DATE, CURRENCY_CODE, SHORT_DESC, LONG_DESC, DICT_L1_CODE_VALUE, LONG_DESC_1                                                                                                                              |
      | FSHEET_CASH_PCAS_LOAD  | TX_NO, PRINCIPAL, INTEREST_RATE, ISSUER, CURRENCY_CODE, INTEREST_BASIS, TOTAL_INTEREST, PERIOD, REM_PERIOD_TO_MATURITY, AUM, RUN_DATE, VALUE_DATE, MATURITY_DATE                                                                                                                         |
      | MAPPING_KURTOSYS       | FUNDNAMES, FUNDCODE, SECTORLEVEL2NAME, COUNTRY, RATINGS, SHEET_NAME, INT_FUND_CODE, HSBC_ISIN_CODE                                                                                                                                                                                       |
      | FSHEET_MASTER_STATIC   | EAGLE_FUND_CD, FUND_NAME, ISIN, OPTION1, OPTION2, OPTION3, STATIC_RANGE                                                                                                                                                                                                                  |
      | FSHEET_GLB_TECH_LOAD   | SEQUENCENUMBER, DATE_COL, FUNDNAME, FUNDCODE, ISINCODE, SHARECLASS, ASSETTYPE, OFFCLISIN, IDENTIFIER, ISSUER, ASSETNAME, HOLDING, VALUE, PERCENT_PORTFOLIO, CURRENCY, PRICE, DIVIDEND, COUNTRY, SECTORLEVEL1NAME, SECTORLEVEL2NAME, RATING, RATINGAGENT, MATURITY, AUM, LONGSHORT, CUSIP |
      | FSHEET_NAV_POSITIONS   | ENTITY_ID, ENTITY_LONG_NAME, EFFECTIVE_DATE, NAV                                                                                                                                                                                                                                         |
      | POSITION_KURTOSYS      | SEQUENCENUMBER, DATE_COL, FUNDNAME, FUNDCODE, ISINCODE, SHARECLASS, ASSETTYPE, OFFCLISIN, IDENTIFIER, ISSUER, ASSETNAME, HOLDING, VALUE, PERCENT_PORTFOLIO, CURRENCY, PRICE, DIVIDEND, COUNTRY, SECTORLEVEL1NAME, SECTORLEVEL2NAME, RATING, RATINGAGENT, MATURITY, AUM, LONGSHORT, CUSIP |
      | KRTS_HSBCLMGB_LOAD     | C_FUND, L_FUND, C_CCY_PTF, TYPE_OF_SECURITIES, C_ID_ISIN, C_ID_SEDOL, L_SEC_NAME, ECONOMIC, COUNTRY, RATING, AGENCY_RATING, PERCENT_AGE,  FEED_CODE, DATE_NAV, AUM                                                                                                                       |
      | FSHEET_FUND_MAP_MASTER | RANGE, FUNDCODE, INTL_FUNDCODE, FUNDNAME, MAP_AUDIT, COUNTRY, SECTOR, RATING, COMMENTARY, FUND_ALLOCATION, HOLDINGS, BOND_CURRENCY, OVERLAY_COUNTRY, OVERLAY_SECTOR, HSBC_ISIN_CODE, SECTOR_DESC, MASTER_FUNDCODE, MASTER_INTL_FUNDCODE                                                  |
      | KRTS_HSBC2190_LOAD     | C_FUND, L_FUND, C_CCY_PTF, TYPE_OF_SECURITIES, C_ID_ISIN, C_ID_SEDOL, L_SEC_NAME, ECONOMIC, COUNTRY, RATING, AGENCY_RATING, PERCENT_AGE, FEED_CODE, DATE_NAV, AUM                                                                                                                        |
      | FSHEET_SGA_GLBGROWTH_LOAD | SEQUENCENUMBER, DATE_COL, FUNDNAME, FUNDCODE, ISINCODE, SHARECLASS, ASSETTYPE, OFFCLISIN, IDENTIFIER, ISSUER, ASSETNAME, HOLDING, VALUE, PERCENT_PORTFOLIO, CURRENCY, PRICE, DIVIDEND, COUNTRY, SECTORLEVEL1NAME, SECTORLEVEL2NAME, RATING, RATINGAGENT, MATURITY, AUM, LONGSHORT, CUSIP, FILE_NAME |