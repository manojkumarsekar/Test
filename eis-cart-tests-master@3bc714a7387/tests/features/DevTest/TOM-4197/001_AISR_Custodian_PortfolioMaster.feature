#https://jira.intranet.asia/browse/TOM-4197

@gc_interface_portfolios
@dmp_regression_unittest
@tom_4197 @tom_4666
Feature: Loading Portfolio file to create FT_T_EXAC for Custodian and setup AISR for shareclass

  Scenario: TC_1: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "AISR_CUST.xlsx" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-4197" to variable "testdata.path"

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


    Then I expect value of column "ID_COUNT_AISR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_AISR
     FROM FT_T_AISR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME='SHare4197')
     AND ACCT_ISSU_RL_TYP='SECSHRECLS'
     AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID ='SG72D0000009' AND ID_CTXT_TYP='ISIN' AND END_TMS IS NULL)
     AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_FRAP" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FRAP
     FROM FT_T_FRAP
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='Test4197' AND END_TMS IS NULL)
     AND FINSRL_TYP='SUBCUST'
     AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID='ES-SG' AND FINS_ID_CTXT_TYP='INHOUSE' AND END_TMS IS NULL)
     AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID='FIID_4197ExtSysId-4197:CUSTDIAN'
     AND EXT_ACCT_NME='BrkNme4197'
     AND EXTERNAL_SYS_ACCT_ID='ExtSysId-4197'
     AND INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='FIID_4197')
     AND FINSRL_TYP='CUSTDIAN'
     AND END_TMS IS NULL
      """


    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='Test4197' AND END_TMS IS NULL)
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='FIID_4197'))
     AND RL_TYP='CUSTDIAN'
     AND END_TMS IS NULL
      """