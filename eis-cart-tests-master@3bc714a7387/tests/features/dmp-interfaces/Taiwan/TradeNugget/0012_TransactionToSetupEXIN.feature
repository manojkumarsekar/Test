#https://jira.intranet.asia/browse/TOM-4582

@tom_4582
Feature: Load Trade file to setup EXIN

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/001_ClearEXTR_ACID.sql
    """

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_4582.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles/0012" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    And I expect value of column "ACID_CNT" in the below SQL query equals to "1":

  """
  SELECT COUNT(*) AS ACID_CNT FROM FT_T_ACID
  WHERE ACCT_ALT_ID ='Test4582'
  AND ACCT_ID_CTXT_TYP = 'CRTSID'
  AND END_TMS IS NULL
  """

  Scenario: Load Fresh data for Trades to setup

    Given I assign "001_tradefile.xml" to variable "INPUT_FILENAME_1"
    And I assign "002_tradefile.xml" to variable "INPUT_FILENAME_2"
    And I assign "003_tradefile.xml" to variable "INPUT_FILENAME_3"

    And I copy files below from local folder "${testdata.path}/infiles/0012" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |
      | ${INPUT_FILENAME_3} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect value of column "EXTR_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXTR_ROW_COUNT FROM FT_T_EXTR
      WHERE TRN_CDE = 'BRSEOD' AND   TRD_PURP_TYP = 'N_P RENOIN'
      AND TRD_ID = '4582-4582'
      AND ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='Test4582' AND END_TMS IS NULL)
      AND END_TMS IS NULL
      """

    And I expect value of column "EXIN_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXIN_ROW_COUNT FROM FT_T_EXIN
      WHERE STL_LOC_MNEM IN (SELECT STL_LOC_MNEM FROM FT_T_SLOC WHERE STL_LOC_TYP ='NO_DELIV' AND END_TMS IS NULL)
      AND EXEC_TRD_ID IN(SELECT EXEC_TRD_ID FROM FT_T_EXTR WHERE TRD_ID ='4582-4582' AND END_TMS IS NULL)
      AND TRN_PROC_INSTRUC_TYP = 'TRDSETTLELOC'
      """

  Scenario: Clear old test data and setup variables

    Given I execute below query
    """
    ${testdata.path}/sql/002_UpdateEXIN.sql
    """

  Scenario: Load trade to test EXIN should not setup a new record.

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect value of column "EXIN_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXIN_ROW_COUNT FROM FT_T_EXIN
      WHERE STL_LOC_MNEM IN (SELECT STL_LOC_MNEM FROM FT_T_SLOC WHERE STL_LOC_TYP ='NO_DELIV' AND END_TMS IS NULL)
      AND EXEC_TRD_ID IN(SELECT EXEC_TRD_ID FROM FT_T_EXTR WHERE TRD_ID ='4582-4582' AND END_TMS IS NULL)
      AND TRN_PROC_INSTRUC_TYP = 'TRDSETTLELOC'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_TRANSACTION-TOM_4582'
      """

  Scenario: Load trade to test EXIN should not setup a new record.

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_3}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect value of column "EXIN_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXIN_ROW_COUNT FROM FT_T_EXIN
      WHERE STL_LOC_MNEM IN (SELECT STL_LOC_MNEM FROM FT_T_SLOC WHERE STL_LOC_TYP ='54X_ALAD' AND END_TMS IS NULL)
      AND EXEC_TRD_ID IN(SELECT EXEC_TRD_ID FROM FT_T_EXTR WHERE TRD_ID ='4582-4582' AND END_TMS IS NULL)
      AND TRN_PROC_INSTRUC_TYP = 'TRDSETTLELOC'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_TRANSACTION'
      """