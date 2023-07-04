#https://jira.pruconnect.net/browse/EISAPPDEV-5
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=60792291

# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 06/08/2019      TOM-5032    First Version
# =====================================================================
   # Business Need : As part of factsheets tactical project, reconcilliation
   # of published internal report files from Azure Vs Eagle files to be performed.
# =====================================================================

@ignore_hooks @factsheet_publish_recon  @factsheet_publish_recon_rhod
Feature: Factsheet (CSV files) Reconciliations for PRU_Rhodium

  As an User, I expect Factsheet (CSV) files generated by 2 different sources (SRC1 & SRC2) should be same.
  Reconciliation should be successful and if any differences between two files will be captured.

  Scenario: Set up Test data paths and prerequisites

    Given I assign "tests/features/factsheet/publish-recon/test-data/PRU_Rhodium/AZURE" to variable "SRC1_TESTDATA_PATH"
    And I assign "tests/features/factsheet/publish-recon/test-data/PRU_Rhodium/EAGLE" to variable "SRC2_TESTDATA_PATH"
    And I assign "tests/features/factsheet/publish-recon/test-data/Exceptions" to variable "EXCEPTIONS_PATH"

  Scenario Outline: Reconciliations of Factsheet : Fund Code "<fund_code>" for "<file>"

    Given I capture current time stamp into variable "recon.timestamp"
    And I assign "${SRC1_TESTDATA_PATH}/<fund_code>/<file>" to variable "SRC1_FILE"
    And I assign "${SRC2_TESTDATA_PATH}/<fund_code>/<file>" to variable "SRC2_FILE"
    And I assign "${EXCEPTIONS_PATH}/exceptions_<fund_code>_<file>_${recon.timestamp}.csv" to variable "EXCP_FILE"

    Then I expect reconciliation between generated CSV file "${SRC1_FILE}" and reference CSV file "${SRC2_FILE}" should be successful and exceptions to be written to "${EXCP_FILE}" file

    Examples: Fund Code SG3837
      | fund_code | file                |
      | SG3837    | COUNTRY.csv         |
      | SG3837    | COUNTRY_DETAILS.csv |
      | SG3837    | MATURITY.csv        |
      | SG3837    | RATINGS.csv         |
      | SG3837    | SECTOR.csv          |
      | SG3837    | SECTOR_DETAILS.csv  |
      | SG3837    | TOP10_HOLDINGS.csv  |
