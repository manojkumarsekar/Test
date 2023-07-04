#https://jira.intranet.asia/browse/TOM-2773
#tom_4158 : update test portfolio and cleardown script
# https://jira.pruconnect.net/browse/EISDEV-6071

# ===================================================================================================================================================================================
# Date            JIRA         Comments
# ===================================================================================================================================================================================
# 19/02/2020      EISDEV-6071  Regression failure :Feature file
# ===================================================================================================================================================================================

@gc_interface_portfolios
@dmp_regression_unittest
@tom_2773 @tom_4158 @eisdev_6071
Feature: Loading Portfolio file to create FT_T_FRAP
  Each vendor should create its own FINS/FIID as there are no common identifiers between them.

  Scenario: TC_7: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "TC_07_PortfolioMaster.xlsx" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-2773" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
      """
      ${testdata.path}/sql/07_ClearDataFINS.sql
      """

    And I execute below query to "Insert FT_T_FINR entry"
      """
      ${testdata.path}/sql/6071_FinrInsert.sql
      """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect value of column "ID_COUNT_FRAP" in the below SQL query equals to "14":
      """
     SELECT COUNT(*) AS ID_COUNT_FRAP
     FROM FT_T_FRAP
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM Ft_t_ACCT WHERE ACCT_NME='2773_TC')
      """

