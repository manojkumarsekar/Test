#https://jira.intranet.asia/browse/TOM-4034
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=50472988
#https://jira.pruconnect.net/browse/EISDEV-7140

@gc_interface_portfolios
@dmp_regression_unittest
@dmp_taiwan
@tom_4034 @portgroup_validdata
@eisdev_7140 @eisdev_7152
Feature: Portfolio Group Interface Testing (R5.IN.DMP Portfolio Group BRS to DMP): For valid portfolio group and Fund

  This interface was created in R3 to publish portfolio group information to the QSG team.
  In R5 the interface data is also loaded to DMP to enable DMP filtering of Taiwan specific information.
  This feature is to test the  portfolio group with valid Fund id gets loaded into DMP

  Scenario: TC_1: Clear the BRS Portfolio Group Data and setup variables as a Prerequisite

    Given I assign "esi_port_group_validData.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioGroup" to variable "testdata.path"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//PORTFOLIO_GROUP//PORTFOLIO_GROUP_NAME[text()='TEST_ASPMMF_GROUP1']/../PORTFOLIO_GROUP_NAME" to variable "PORTFOLIO_GROUP_NAME1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//PORTFOLIO_GROUP//PORTFOLIO_GROUP_NAME[text()='TEST_ABBOTF_GROUP2']/../PORTFOLIO_GROUP_NAME" to variable "PORTFOLIO_GROUP_NAME2"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//PORTFOLIO_GROUP//PORTFOLIO_GROUP_NAME[text()='TEST_TT16_GROUP3']/../PORTFOLIO_GROUP_NAME" to variable "PORTFOLIO_GROUP_NAME3"

    And I execute below query
    """
    DELETE FT_T_ACGP WHERE  PRNT_ACCT_GRP_OID IN (SELECT ACCT_GRP_OID FROM FT_T_ACGR  WHERE  GRP_NME IN('${PORTFOLIO_GROUP_NAME1}', '${PORTFOLIO_GROUP_NAME2}','${PORTFOLIO_GROUP_NAME3}'));
    DELETE FT_T_CCRF WHERE  ACCT_GRP_OID IN (SELECT ACCT_GRP_OID FROM   FT_T_ACGR WHERE  GRP_NME IN('${PORTFOLIO_GROUP_NAME1}', '${PORTFOLIO_GROUP_NAME2}','${PORTFOLIO_GROUP_NAME3}'));
    DELETE FT_T_ACGR WHERE  GRP_NME IN('${PORTFOLIO_GROUP_NAME1}', '${PORTFOLIO_GROUP_NAME2}','${PORTFOLIO_GROUP_NAME3}');
    COMMIT
    """

  Scenario: TC_2: Load portfolio group file from BRS to DMP for group TEST_TT56_GROUP1, TEST_TT27_GROUP2,TEST_TT16_GROUP3 and verify all are loaded successfully into DMP

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |
      | BUSINESS_FEED |                            |

    Then I expect workflow is processed in DMP with total record count as "3"
    Then I expect workflow is processed in DMP with success record count as "3"

   # Validation 1: Portfolio Group - Total Successfully Processed ACGR Records => 3 records should be created in ACGR
    Then I expect value of column "ACGR_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
    """
    SELECT Count(*) AS ACGR_PROCESSED_ROW_COUNT
    FROM   FT_T_ACGR
    WHERE  GRP_NME IN('${PORTFOLIO_GROUP_NAME1}', '${PORTFOLIO_GROUP_NAME2}','${PORTFOLIO_GROUP_NAME3}')
    AND GRP_PURP_TYP='UNIVERSE'
    AND ACCT_GRP_ID IN ('${PORTFOLIO_GROUP_NAME1}', '${PORTFOLIO_GROUP_NAME2}','${PORTFOLIO_GROUP_NAME3}')
    AND END_TMS is null
    """

   # Validation 2: Portfolio Group - Total Successfully Processed ACGP Records => 3 records should be created in ACGP
    Then I expect value of column "ACGP_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
    """
    SELECT Count(*) AS ACGP_PROCESSED_ROW_COUNT
    FROM FT_T_ACGP
    WHERE PRNT_ACCT_GRP_OID IN (SELECT ACCT_GRP_OID FROM   FT_T_ACGR  WHERE  GRP_NME IN('${PORTFOLIO_GROUP_NAME1}', '${PORTFOLIO_GROUP_NAME2}','${PORTFOLIO_GROUP_NAME3}')  AND END_TMS is null)
    AND PRT_DESC='BRS Portfolio Group'
    AND PRT_PURP_TYP ='MEMBER'
    """

   # Validation 3: Verify PORTFOLIO_GROUP_FULL_NAME is null for TEST_TT16_GROUP3 group
    Then I expect value of column "ACGR_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT Count(*) AS ACGR_ROW_COUNT
    FROM   FT_T_ACGR
    WHERE  GRP_NME IN('${PORTFOLIO_GROUP_NAME3}')
    AND END_TMS is null
    AND GRP_DESC is null
    """

