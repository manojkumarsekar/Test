#https://jira.pruconnect.net/browse/EISDEV-7262
#https://collaborate.pruconnect.net/display/EISPRM/Share+class+Integration
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=ShareClass+Integration

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 21/12/2020      EISDEV-7262    Expose fundipedia fields in Portfolio Uploader
# ===================================================================================================================================================================================


@dmp_regression_unittest @gc_interface_shareclass @gc_interface_fundipedia
@eisdev_7262 @eisdev_7262_shareclass_fields_uploader

Feature: Fundipedia shareclass fields exposed in UI

  This feature tests the below scenarios
  1. New shareclass created via portfolio uploader updates the fundipedia fields as expected
  2. Existing shareclass updated via portfolio uploader updates the fundipedia fields as expected

  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-7262" to variable "testdata.path"
    And I assign "Portfolio_Uploader_Fundipedia_Fields.xlsx" to variable "INPUT_FILE_NAME"

  Scenario: Load the share class uploader file

    When I process "${testdata.path}/testdata/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario Outline: Verify the fundipedia fields saved correctly against the shareclass

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples:
      | Column             | Query                                                                                                                                                                                                                                       |
      | ShareclassIDNew    | SELECT CASE WHEN ACCT_ALT_ID = '001' THEN 'PASS' ELSE 'FAIL' END AS ShareclassIDNew FROM FT_T_ACID WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'AUTOSC001') AND ACCT_ID_CTXT_TYP = 'FSHRCLSID' AND END_TMS IS NULL  |
      | FundIDNew          | SELECT CASE WHEN STAT_CHAR_VAL_TXT = '003' THEN 'PASS' ELSE 'FAIL' END AS FundIDNew FROM FT_T_ACST WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'AUTOSC001') AND STAT_DEF_ID = 'FFUNDID' AND END_TMS IS NULL         |
      | PortfolioIDNew     | SELECT CASE WHEN ACCT_ALT_ID = '002' THEN 'PASS' ELSE 'FAIL' END AS PortfolioIDNew FROM FT_T_ACID WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'AUTOSC001') AND ACCT_ID_CTXT_TYP = 'FPORTID' AND END_TMS IS NULL     |
      | ShareclassIDUpdate | SELECT CASE WHEN ACCT_ALT_ID = '291' THEN 'PASS' ELSE 'FAIL' END AS ShareclassIDUpdate FROM FT_T_ACID WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALDAEFE') AND ACCT_ID_CTXT_TYP = 'FSHRCLSID' AND END_TMS IS NULL |
      | FundIDUpdate       | SELECT CASE WHEN STAT_CHAR_VAL_TXT = '1' THEN 'PASS' ELSE 'FAIL' END AS FundIDUpdate FROM FT_T_ACST WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALDAEFE') AND STAT_DEF_ID = 'FFUNDID' AND END_TMS IS NULL          |
      | PortfolioIDUpdate  | SELECT CASE WHEN ACCT_ALT_ID = '55' THEN 'PASS' ELSE 'FAIL' END AS PortfolioIDUpdate FROM FT_T_ACID WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALDAEFE') AND ACCT_ID_CTXT_TYP = 'FPORTID' AND END_TMS IS NULL     |

  Scenario Outline: Verify the fundipedia fields saved correctly against the portfolio

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples:
      | Column            | Query                                                                                                                                                                                                                                    |
      | FundIDNew         | SELECT CASE WHEN STAT_CHAR_VAL_TXT = '12' THEN 'PASS' ELSE 'FAIL' END AS FundIDNew FROM FT_T_ACST WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCITEST001') AND STAT_DEF_ID = 'FFUNDID' AND END_TMS IS NULL      |
      | PortfolioIDNew    | SELECT CASE WHEN ACCT_ALT_ID = '006' THEN 'PASS' ELSE 'FAIL' END AS PortfolioIDNew FROM FT_T_ACID WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCITEST001') AND ACCT_ID_CTXT_TYP = 'FPORTID' AND END_TMS IS NULL |
      | FundIDUpdate      | SELECT CASE WHEN STAT_CHAR_VAL_TXT = '280' THEN 'PASS' ELSE 'FAIL' END AS FundIDUpdate FROM FT_T_ACST WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALAEIF') AND STAT_DEF_ID = 'FFUNDID' AND END_TMS IS NULL      |
      | PortfolioIDUpdate | SELECT CASE WHEN ACCT_ALT_ID = '56' THEN 'PASS' ELSE 'FAIL' END AS PortfolioIDUpdate FROM FT_T_ACID WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALAEIF') AND ACCT_ID_CTXT_TYP = 'FPORTID' AND END_TMS IS NULL   |






