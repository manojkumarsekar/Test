#https://jira.intranet.asia/browse/TOM-4035

@gc_interface_portfolios
@dmp_regression_unittest
@tom_4103 @tom_4035
Feature: share class is able to link with multiple main portfolio in GS but it should overwrite the existing one instead of creating new record in ACCR table.

  Scenario: TC_1: Setup share class and FT_T_ACCR table should be create

    Given I assign "TC-01.xlsx" to variable "INPUT_FILENAME_1"
    And I assign "TC-02.xlsx" to variable "INPUT_FILENAME_2"
    And I assign "tests/test-data/DevTest/TOM-4035" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |


    And I execute below query to "Clear data from FT_T_ACCR"
      """
      ${testdata.path}/sql/01_ClearACCR.sql
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_1}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect value of column "ACCR_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ACCR_COUNT FROM FT_T_ACCR
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = 'share4035')
    AND REP_ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = 'Port4035' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    """

  Scenario: TC_2: Setup share class and FT_T_ACCR table should be create with latest portfolio

    Given I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect value of column "ACCR_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ACCR_COUNT FROM FT_T_ACCR
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = 'share4035')
    AND REP_ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'Port4103' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    """

    Then I expect value of column "ACCR_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS ACCR_COUNT FROM FT_T_ACCR
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = 'share4035')
    AND REP_ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = 'Port4035')
    """
