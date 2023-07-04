#https://jira.intranet.asia/browse/TOM-2773
#tom_4158 : update test portfolio and cleardown script

@gc_interface_securities @gc_interface_cash
@dmp_regression_integrationtest
@tom_2773 @tom_4158
Feature: Loading BNP files to create FinancialInsitution

  Each vendor should create its own FINS/FIID as there are no common identifiers between them.

  Scenario: TC_1: Load files for EIS_BNP_DMP_SECURITY

    Given I assign "TC-02_BNP_SEC.out" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-2773" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
    """
    ${testdata.path}/sql/02_ClearDataFINS.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    Then I expect value of column "ID_COUNT_FINS" in the below SQL query equals to "3":
      """
     SELECT COUNT(*) AS ID_COUNT_FINS
     FROM FT_T_FINS
     WHERE INST_NME IN ('TESTFINS','HOUSE_CODE','MEMBER_CODE')
      """
    Then I expect value of column "ID_COUNT_FIID" in the below SQL query equals to "3":
      """
     SELECT COUNT(*) AS ID_COUNT_FIID
     FROM FT_T_FIID
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME IN ('TESTFINS','HOUSE_CODE','MEMBER_CODE'))
      """
    Then I expect value of column "ID_COUNT_FINR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FINR
     FROM FT_T_FINR
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME IN ('TESTFINS','HOUSE_CODE','MEMBER_CODE'))
      """

    Then I expect value of column "ID_COUNT_FRIP" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FRIP
     FROM FT_T_FRIP
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME IN ('TESTFINS','HOUSE_CODE','MEMBER_CODE'))
      """

    Then I expect value of column "ID_COUNT_FFRL" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FFRL
     FROM FT_T_FFRL
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME IN ('TESTFINS','HOUSE_CODE','MEMBER_CODE'))
      """

  Scenario: TC_2: Load files for EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION

    Given I assign "TC-03-BNP_CASH_TRN.out" to variable "INPUT_FILENAME_2"

     # Clear data from FINS and its Child table
    And I execute below query
    """
    ${testdata.path}/sql/03_ClearDataFINS.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                  |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

    Then I expect value of column "ID_COUNT_FINS" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FINS
     FROM FT_T_FINS
     WHERE INST_NME='TESTFINS_1'
      """
    Then I expect value of column "ID_COUNT_FIID" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FIID
     FROM FT_T_FIID
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME='TESTFINS_1')
      """
    Then I expect value of column "ID_COUNT_FINR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FINR
     FROM FT_T_FINR
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FINS WHERE INST_NME ='TESTFINS_1')
      """
