#https://jira.pruconnect.net/browse/EISDEV-6721
#Requirement: https://collaborate.pruconnect.net/display/EISTT/TH+Portfolio+Master%7CTFUND%7CTMBAM#businessRequirements-508441805
#Technical specification : https://collaborate.pruconnect.net/display/EISTOMR4/TH+-+GS+Portfolio+Master+Enhancements


# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 18/03/2021      EISDEV-7451    Custodian value not displayed in UI and IDMV lookup change to description instead of name
# =========== ========================================================================================================================================================================

@gc_interface_portfolios
@dmp_regression_unittest
@eisdev_6721 @eisdev_6721_nonui @001_portfolios_hiport_suffix_code @dmp_thailand_portfolios @dmp_thailand @eisdev_7451
Feature: This feature is to test  HIPORT_SUFFIX_CODE newly added columns using uploader

  Additional attribute required in Golden source portfolio master GUI and portfolio master upload, this field is require for TMBAM or TFUND or TMB
  This feature file is to test create or update the HIPORT_SUFFIX_CODE.

  Scenario: Initialize variables and Deactivate Existing test accounts to maintain clean state before executing tests
    Given I assign "002_DMP_R3_PortfolioMasteringTemplate_Final_4.12.xlsx" to variable "INPUT_FILENAME"
    And I assign "002_DMP_R3_PortfolioMasteringTemplate_Final_4.12_Update.xlsx" to variable "INPUT_FILENAME_FOR_UPDATE"
    And I assign "tests/test-data/dmp-interfaces/Thailand/Portfolio/Uploader" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I extract below values for row 2 from EXCEL file "${INPUT_FILENAME}" in local folder "${testdata.path}/infiles" and assign to variables:
      | HIPORT_SUFFIX_CD | VAR_HIPORT_SUFFIX_CODE_INSERT |
    And I extract below values for row 2 from EXCEL file "${INPUT_FILENAME_FOR_UPDATE}" in local folder "${testdata.path}/infiles" and assign to variables:
      | HIPORT_SUFFIX_CD | VAR_HIPORT_SUFFIX_CODE_UPDATE |
    And I execute below query to "deactivate the existing records, so that we can validate the insert and update"
    """
    UPDATE ft_t_acid SET end_tms = sysdate
    WHERE ACCT_ALT_ID in ('${VAR_HIPORT_SUFFIX_CODE_INSERT}','${VAR_HIPORT_SUFFIX_CODE_UPDATE}') AND end_tms is null
    """

  Scenario: Process Portfolio Master template to create new Account and verify its processed successfully

    Given I process "${testdata.path}/infiles/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:  Verify new Account created with HIPORT_SUFFIX_CD in FT_T_ACID table
    Then I expect value of column "HIPORTSFXCD_CREATE_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS HIPORTSFXCD_CREATE_RECORD_COUNT FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '${VAR_HIPORT_SUFFIX_CODE_INSERT}'
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ACCT_ID_CTXT_TYP = 'HIPORTSFXCD'
    AND DATA_SRC_ID  = 'EIS'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND END_TMS IS NULL
    """

    Then I expect value of column "CUSTODIAN" in the below SQL query equals to "CITI NY":
    """
    SELECT FIID.FINS_ID AS CUSTODIAN
    FROM FT_T_FRAP FRAP, FT_T_FINR FINR, FT_T_FIID FIID WHERE
    FIID.FINS_ID_CTXT_TYP='INHOUSE' AND FIID.INST_MNEM=FINR.INST_MNEM AND FIID.END_TMS IS NULL AND
    FINR.FINSRL_TYP=FRAP.FINSRL_TYP AND FINR.INST_MNEM=FRAP.INST_MNEM AND FINR.END_TMS IS NULL AND
    FRAP.FINSRL_TYP ='CUSTDIAN' AND FRAP.PRT_PURP_TYP ='CUSTODIA' AND FRAP.END_TMS IS NULL AND
    FRAP.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '${VAR_HIPORT_SUFFIX_CODE_INSERT}' AND END_TMS IS NULL)
    """

  Scenario: Process Portfolio Master template to update existing Account and verify its processed successfully

    Given I process "${testdata.path}/infiles/${INPUT_FILENAME_FOR_UPDATE}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_FOR_UPDATE}         |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario:  Verify Account is updated with new HIPORT_SUFFIX_CD in FT_T_ACID table
    Then I expect value of column "HIPORTSFXCD_UPDATE_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS HIPORTSFXCD_UPDATE_RECORD_COUNT FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '${VAR_HIPORT_SUFFIX_CODE_UPDATE}'
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ACCT_ID_CTXT_TYP    = 'HIPORTSFXCD'
    AND DATA_SRC_ID         = 'EIS'
    AND LAST_CHG_USR_ID     = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND END_TMS IS NULL
    """


