#https://jira.intranet.asia/browse/TOM-4691

@tom_4691
Feature: To verify load of UDF field TW CP Intr Tax

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/0013_ClearEXTR_ACID.sql
    """

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_4691.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles/0013" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    And I expect value of column "ACID_CNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACID_CNT FROM FT_T_ACID
      WHERE ACCT_ALT_ID ='Test4691'
      AND ACCT_ID_CTXT_TYP = 'CRTSID'
      AND END_TMS IS NULL
      """

  Scenario: Load F10 to setup Security

    Given I assign "001_sm_4691.xml" to variable "INPUT_FILENAME_1"

    And I copy files below from local folder "${testdata.path}/infiles/0013" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    And I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS ISID_ROW_COUNT FROM FT_T_ISID WHERE ISS_ID = 'BES2NFF75' AND END_TMS IS NULL
      """

  Scenario: Load Trade Nugget and verify if UDF with label TW CP Intr Tax was loaded in ETPY

    Given I assign "001_tradefile_4691.xml" to variable "INPUT_FILENAME_1"

    And I copy files below from local folder "${testdata.path}/infiles/0013" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I expect value of column "EXTR_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXTR_ROW_COUNT FROM FT_T_EXTR
      WHERE TRN_CDE = 'BRSEOD'
      AND TRD_ID = '4691-4691'
      AND ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='Test4691' AND END_TMS IS NULL)
      AND END_TMS IS NULL
      """

    And I expect value of column "ETPY_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ETPY_ROW_COUNT FROM FT_T_ETPY
      WHERE EXEC_TRD_PAY_TYP = 'TWCPINTTX'
      AND EXEC_TRD_ID IN (SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRN_CDE = 'BRSEOD' AND TRD_ID = '4691-4691'
      AND ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='Test4691' AND END_TMS IS NULL)
      AND END_TMS IS NULL)
      """