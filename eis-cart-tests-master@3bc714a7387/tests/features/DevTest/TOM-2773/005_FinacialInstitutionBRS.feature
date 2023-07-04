#https://jira.intranet.asia/browse/TOM-2773
#tom_4158 : update test portfolio and cleardown script

@gc_interface_issuer
@dmp_regression_unittest
@tom_2773 @tom_4158
Feature: Loading BRS files to create FinancialInsitution

  Each vendor should create its own FINS/FIID as there are no common identifiers between them.

  Scenario: TC_1: Load files for EIS_BRS_DMP_ISSUER

    Given I assign "TC-06-RDM_ISSUER.xml" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-2773" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
    """
    ${testdata.path}/sql/06_ClearDataFINS.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER   |

    Then I expect value of column "ID_COUNT_FINS" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FINS
     FROM FT_T_FINS
     WHERE INST_NME IN ('BNP PARIBAS SA') AND DATA_SRC_ID <> 'REUTERS'
      """
    Then I expect value of column "ID_COUNT_FIID" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FIID
     FROM FT_T_FIID
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME IN ('BNP PARIBAS SA') AND DATA_SRC_ID <> 'REUTERS')
      """
    Then I expect value of column "ID_COUNT_FINR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FINR
     FROM FT_T_FINR
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME IN ('BNP PARIBAS SA') AND DATA_SRC_ID <> 'REUTERS')
      """

