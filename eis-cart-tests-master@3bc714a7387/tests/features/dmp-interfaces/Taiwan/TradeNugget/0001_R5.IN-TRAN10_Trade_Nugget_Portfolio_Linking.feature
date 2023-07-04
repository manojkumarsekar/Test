#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades

@gc_interface_transactions
@dmp_regression_unittest
@dmp_taiwan
@tom_3844 @trades_portfolio_linking
Feature: Inbound Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Portfolio linking

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Portfolio not present in DMP should raise 26 notification and reject transaction record

    Given I assign "tc_1_equity_equity_invalid_portfolio.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_invalid_portfolio' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0001" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has one OPEN Notification for 26
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 26 AND MSG_SEVERITY_CDE = 50 AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

  Scenario: TC_2: Portfolio present in DMP should get processed succesfully

    Given I assign "tc_2_equity_equity_valid_portfolio.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_valid_portfolio' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0001" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

  # Check if NTEL has no OPEN Notification for 26
    Then I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS NTEL_VALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 26 AND MSG_SEVERITY_CDE = 50 AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

    # Check if NTEL has no OPEN Notification for 60021
    Then I expect value of column "EXTR_VALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS EXTR_VALID_COUNT FROM FT_T_EXTR WHERE AUOR_OID IS NOT NULL AND EXEC_TRD_ID IN
      (SELECT DISTINCT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE XREF_TBL_TYP = 'EXTR' AND TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}') WHERE R=1)))
      """

    #  Added by Test Team
  Scenario: TC_3:Verify missing security and Portfolio in BRS file raise exception

    Given I assign "BondGovt_Missing_CUSIP_Portfolio.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles/regression" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS NTEL_ROW_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60001 AND MSG_SEVERITY_CDE = 40 AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID ='${JOB_ID}')
      """