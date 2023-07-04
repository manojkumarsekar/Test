# ===================================================================================================================================================================================
# Date            JIRA          Comments
# ===================================================================================================================================================================================
# 21/10/2020      EISDEV-7002   New Attribute PORTFOLIO_ISIN added for Portfolio and ShareClass Uploader
# ===================================================================================================================================================================================

@gc_interface_portfolios
@dmp_regression_unittest
@eisdev_7002 @001_portfolio_isin
Feature: Portfolio Uploader | ACID | PORTFOLIO_ISIN

  Additional attribute required in Golden source portfolio master GUI and portfolio master upload,
  This feature file is to test create or update the PORTFOLIO_ISIN.

  Scenario: Initialize variables and Deactivate Existing test accounts to maintain clean state before executing tests
    Given I assign "002_DMP_R3_PortfolioMasteringTemplate_Final_4.13.xlsx" to variable "INPUT_FILENAME"
    And I assign "002_DMP_R3_PortfolioMasteringTemplate_Final_4.13_Update.xlsx" to variable "INPUT_FILENAME_FOR_UPDATE"
    And I assign "tests/test-data/dmp-interfaces/Portfolio/Inbound" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I execute below query to "deactivate the existing records, so that we can validate the insert and update"
    """
    UPDATE ft_t_acid SET end_tms = sysdate
    WHERE ACCT_ALT_ID like 'EISDEV7002_PISIN_%' AND end_tms is null
    """

  Scenario: Process Portfolio Master template to create new Account and verify its processed successfully

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:  Verify new Account created with PORTFOLIOISIN in FT_T_ACID table
    Then I expect value of column "PORTFOLIOISIN_INSERT" in the below SQL query equals to "EISDEV7002_PISIN_PORTFOLIO_INSERT":
    """
    select ACCT_ALT_ID as PORTFOLIOISIN_INSERT from ft_t_acid
    where ACCT_ID_CTXT_TYP = 'PORTFOLIOISIN'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'EISDEV7002_IPRID'
    and ACCT_ID_CTXT_TYP = 'IRPID' and end_tms is null) and end_tms is null
    """

  Scenario:  Verify new ShareClass created with PORTFOLIOISIN in FT_T_ACID table
    Then I expect value of column "PORTFOLIOISIN_SHARECLASS_INSERT" in the below SQL query equals to "EISDEV7002_PISIN_SHARECLASS_INSERT":
    """
    select ACCT_ALT_ID as PORTFOLIOISIN_SHARECLASS_INSERT from ft_t_acid where ACCT_ID_CTXT_TYP = 'PORTFOLIOISIN'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'EISDEV7002'
    and ACCT_ID_CTXT_TYP = 'IRPID' and end_tms is null) and end_tms is null
    """

  Scenario: Process Portfolio Master template to update existing Account and verify its processed successfully

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_FOR_UPDATE}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_FOR_UPDATE}         |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:  Verify new Account updated with PORTFOLIOISIN in FT_T_ACID table
    Then I expect value of column "PORTFOLIOISIN_INSERT" in the below SQL query equals to "EISDEV7002_PISIN_PORTFOLIO_UPDATE":
    """
    select ACCT_ALT_ID as PORTFOLIOISIN_INSERT from ft_t_acid
    where ACCT_ID_CTXT_TYP = 'PORTFOLIOISIN'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'EISDEV7002_IPRID'
    and ACCT_ID_CTXT_TYP = 'IRPID' and end_tms is null) and end_tms is null
    """

  Scenario:  Verify new ShareClass updated with PORTFOLIOISIN in FT_T_ACID table
    Then I expect value of column "PORTFOLIOISIN_SHARECLASS_INSERT" in the below SQL query equals to "EISDEV7002_PISIN_SHARECLASS_UPDATE":
    """
    select ACCT_ALT_ID as PORTFOLIOISIN_SHARECLASS_INSERT from ft_t_acid where ACCT_ID_CTXT_TYP = 'PORTFOLIOISIN'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'EISDEV7002'
    and ACCT_ID_CTXT_TYP = 'IRPID' and end_tms is null) and end_tms is null
    """