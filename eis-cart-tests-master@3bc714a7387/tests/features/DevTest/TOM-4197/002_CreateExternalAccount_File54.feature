#https://jira.intranet.asia/browse/TOM-4197

@gc_interface_portfolios
@dmp_regression_unittest
@tom_4197
Feature: Loading Portfolio file for BRS to create FT_T_EXAC for Custodian

  Scenario: TC_1: Load files for EIS_BRS_DMP_PORTFOLIO

    Given I assign "BRS_PORTFOLIO_1.xml" to variable "INPUT_FILENAME_1"
    And I assign "CustodianMissing.xml" to variable "INPUT_FILENAME_2"
    And I assign "FundMissing.xml" to variable "INPUT_FILENAME_3"
    And I assign "tests/test-data/DevTest/TOM-4197" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
      """
      ${testdata.path}/sql/02_CleanupANDInsertFINS.sql
      """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |
      | ${INPUT_FILENAME_3} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID='METZLER000053894001:CUSTDIAN'
     AND EXTERNAL_SYS_ACCT_ID='000053894001'
     AND INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='METZLER ASSET MANAGEMENT GMBH GERMANY')
     AND FINSRL_TYP='CUSTDIAN'
     AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='3434' AND END_TMS IS NULL)
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='METZLER ASSET MANAGEMENT GMBH GERMANY'))
     AND RL_TYP='CUSTDIAN'
     AND END_TMS IS NULL
      """

  Scenario: TC_2: Load files for EIS_BRS_DMP_PORTFOLIO to check missing custodian

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS NTEL_COUNT
     FROM FT_T_NTEL
     WHERE NOTFCN_ID='60001'
     AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields,CUSTODIANis not present in the input record'
     AND NOTFCN_STAT_TYP='OPEN'
     AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

  Scenario: TC_3: Load files for EIS_BRS_DMP_PORTFOLIO to check missing Fund

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_3}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS NTEL_COUNT
     FROM FT_T_NTEL
     WHERE NOTFCN_ID='60001'
     AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fieldsFUNDis not present in the input record'
     AND NOTFCN_STAT_TYP='OPEN'
     AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """
