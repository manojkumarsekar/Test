#https://jira.intranet.asia/browse/TOM-3930

@gc_interface_portfolios
@dmp_regression_unittest
@tom_4105 @tom_3930
Feature: Loading Portfolio file to create FT_T_EXAC
  1) Load a file to setup SCUNIBUSNUM in FT_T_ACID table for shareclass.
  2) Link Hedge portfolio to shareclass.
  3) To setup FT_T_EXAC.

  Scenario: TC_1: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "BrokerPortfolio.xlsx" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-3930" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
      """
      ${testdata.path}/sql/01_CleanupANDInsertFINS.sql
      """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect value of column "ID_COUNT_ACID" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_ACID
     FROM FT_T_ACID
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='SHare3930')
     AND ACCT_ID_CTXT_TYP='SCUNIBUSNUM'
     AND ACCT_ALT_ID='Share_Uniform'
     AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_ACID" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_ACID
     FROM FT_T_ACID
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='Test3930')
     AND ACCT_ID_CTXT_TYP='UNIBUSNUM'
     AND ACCT_ALT_ID='Port_Uniform'
     AND END_TMS IS NULL
      """


    Then I expect value of column "ID_COUNT_ACID" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_ACID
     FROM FT_T_ACID
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='SHare3930')
     AND ACCT_ID_CTXT_TYP='SCSITCAFNDID'
     AND ACCT_ALT_ID='Share_Sitca'
     AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_ACID" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_ACID
     FROM FT_T_ACID
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='Test3930')
     AND ACCT_ID_CTXT_TYP='SITCAFNDID'
     AND ACCT_ALT_ID='Port_Sitca'
     AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_ACCR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_ACCR
     FROM FT_T_ACCR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='SHare3930')
     AND REP_ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='Test3930')
	 AND RL_TYP='HEDGE'
     AND END_TMS IS NULL
      """


    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID='FIID_3930ExtSysId-3930:BROKER'
     AND EXT_ACCT_NME='BrkNme3930'
     AND EXTERNAL_SYS_ACCT_ID='ExtSysId-3930'
     AND INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='FIID_3930')
     AND END_TMS IS NULL
      """


    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='Test3930')
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='FIID_3930'))
     AND END_TMS IS NULL
      """