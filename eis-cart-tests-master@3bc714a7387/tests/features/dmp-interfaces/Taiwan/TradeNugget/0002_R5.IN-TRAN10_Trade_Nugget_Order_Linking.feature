#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades

#TOM-3844 - Initial development
#TOM-4054 - Fix failure when multiple order allocations
#TOM-4057 - Test matching when there are multiple active allocations
#EIDEV-6226 - Regression Issue- the BCSUIP was enddated in db. Solution - end_tms is null condition was missing in query to get iss_id from db. Added the same.

@gc_interface_transactions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3844 @trades_order_linking @tom_4054 @tom_4057 @eisdev_6226 @eisdev_6869
Feature: Inbound Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Order linking

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Order not present in DMP should raise 60021 notification and reject transaction record

    Given I assign "tc_1_equity_equity_invalid_order.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_invalid_order' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0002" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has one OPEN Notification for 60021
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60021 AND MSG_SEVERITY_CDE = 30 AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

  Scenario: TC_2: Order present in DMP should get processed succesfully

    Given I assign "tc_2_equity_equity_valid_order.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_valid_order' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0002" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

  # Check if NTEL has no OPEN Notification for 60021
    Then I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS NTEL_VALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60021 AND MSG_SEVERITY_CDE = 50 AND LAST_CHG_TRN_ID IN
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

  Scenario: TC_3: Order present in DMP with multiple allocations; should get processed succesfully

    Given I assign "tc_3_equity_equity_valid_order_inactive_alloc.xml" to variable "INPUT_FILENAME"
    And I assign "0002_tc_3_equity_equity_valid_order_inactive_alloc_template.xml" to variable "TEMPLATE_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_valid_order_multiple_alloc' AND END_TMS IS NULL
    """

    # We will find an existing order that has, for the same account, an active and inactive allocation
    And I execute below query and extract values of "PREF_ORDER_ID;ACCT_CRTS_ID;INSTR_BCUSIP;INSTR_NAME" into same variables
     """
     ${testdata.path}/sql/GetOrderWithInactiveDataStatTyp.sql
     """

    And I create input file "${INPUT_FILENAME}" using template "${TEMPLATE_FILENAME}" with below codes from location "${testdata.path}/infiles"
      |  |  |

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

# Check if NTEL has no OPEN Notification for 60021
    Then I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS NTEL_VALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60021 AND MSG_SEVERITY_CDE = 50 AND LAST_CHG_TRN_ID IN
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

  Scenario: TC4: Order present in DMP with multiple allocations, all of which are active; should get processed succesfully

    Given I assign "tc_4_equity_equity_valid_order_n_active_alloc.xml" to variable "INPUT_FILENAME"
    And I assign "0002_tc_4_equity_equity_valid_order_n_active_alloc_template.xml" to variable "TEMPLATE_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_valid_order_n_active_alloc' AND END_TMS IS NULL
    """

    # We will find an existing order that has, for the same account, an active and inactive allocation
    And I execute below query and extract values of "PREF_ORDER_ID;ACCT_CRTS_ID;INSTR_BCUSIP;INSTR_NAME" into same variables
     """
     ${testdata.path}/sql/GetOrderWithMultipleActiveDataStatTyp.sql
     """

    And I create input file "${INPUT_FILENAME}" using template "${TEMPLATE_FILENAME}" with below codes from location "${testdata.path}/infiles"
      |  |  |

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has no OPEN Notification for 60021
    Then I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS NTEL_VALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60021 AND MSG_SEVERITY_CDE = 30 AND LAST_CHG_TRN_ID IN
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
