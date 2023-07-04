#https://jira.pruconnect.net/browse/EISDEV-6983
#https://collaborate.pruconnect.net/display/EISPRM/Portfolio+Integration
#https://collaborate.pruconnect.net/display/EISTOMR4/Portfolio+Integration

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 14/12/2020      EISDEV-6983    Portfolio Integration
# ===================================================================================================================================================================================


@dmp_regression_integrationtest @gc_interface_portfolio @gc_interface_fundipedia
@eisdev_6983 @eisdev_6983_crtsid_not_present @eisdev_7283

Feature: Load Portfolio for CRTS ID not present in GS

  This feature tests the below scenarios
  1. The CRTS ID received is not present in GS. Entity status type = Active.
  2. The CRTS ID received is not present in GS. Entity status type = Archived.
  3. The CRTS ID received is not present in GS. Entity status type = Deleted.
  4. The CRTS ID received is not present in GS. Entity status type = Created.


  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-6983" to variable "testdata.path"
    And I assign "Portfolio_CRTS_ID_Not_Present.xml" to variable "INPUT_FILE_NAME"

  Scenario: Load the share class file

    When I process "${testdata.path}/testdata/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                   |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_PORTFOLIO_INTG |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"
    And I expect workflow is processed in DMP with success record count as "3"
    And I expect workflow is processed in DMP with filtered record count as "1"

  Scenario Outline: Verify the values saved in ACST table

    Then I expect value of column "CRTSIDCount" in the below SQL query equals to "<Value>":

    """
 SELECT COUNT(*) AS CRTSIDCount FROM FT_T_ACID
  WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '<CRTSID>')
   AND ACCT_ID_CTXT_TYP = 'CRTSID'
  """

  Examples:
    | CRTSID      | Value |
    | AUTOTEST001 | 1     |
    | AUTOTEST002 | 0     |
    | AUTOTEST003 | 0     |
    | AUTOTEST004 | 0     |
