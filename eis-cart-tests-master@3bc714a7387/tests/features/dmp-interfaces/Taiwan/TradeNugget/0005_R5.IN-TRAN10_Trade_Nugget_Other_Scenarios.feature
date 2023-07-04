#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#https://jira.intranet.asia/browse/TOM-4147
#https://jira.intranet.asia/browse/TOM-4165
#https://jira.intranet.asia/browse/TOM-4196 => ORD_NUM not available in DMP should raise exception but should not fail the segment load

@tom_4196 @tom_4165 @tom_4147 @tom_3844 @trades_other_scenarios
Feature: Inbound Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Portfolio linking

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Change in TRD_ORIG_FACE should not create new EXTR but update existing one

    Given I assign "tc_1_equity_equity_trd_orig_face_change.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_trd_org_face_change' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if only one EXTR was created
    Then I expect value of column "EXTR_VALID_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(1) AS EXTR_VALID_COUNT FROM FT_T_EXTR WHERE END_TMS IS NULL AND EXEC_TRD_ID IN
      (SELECT DISTINCT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE XREF_TBL_TYP = 'EXTR' AND TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}') WHERE R=1)))
      """

  Scenario: TC_2: Missing PORTFOLIO CODE & INV_NUM should raise exception

    Given I assign "tc_2_equity_equity_missing_port_invnum.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has one OPEN Notification for 60001
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60001 AND MSG_SEVERITY_CDE = 40
      AND CHAR_VAL_TXT = 'Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields PORTFOLIOS PORTFOLIO NAME, INVNUM is not present in the input record.'
      AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

  Scenario: TC_3: TRAN_TYPE1, TRAN_TYP2 & TRD_ORIG_FACE combination not present in the configuration should raise exception for ETCL where INDUS_CL_SET_ID = 'BRSTRTYP'

    Given I assign "tc_3_equity_equity_tran_type_derivation.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_tran_type' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has one OPEN Notification for 60020
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60020 AND MSG_SEVERITY_CDE = 40
      AND CHAR_VAL_TXT = 'The External Industry Classification for ''BRSTRTYP - CMAT::-'' received from BRS  not found in the  ExternalIndustryClassification Table.'
      AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

  Scenario: TC_4: TRAN_TYPE1 not present in IDMV should reject the entire record and fail with Sev-50

    Given I assign "tc_4_equity_equity_tran_type1_notfound.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_tran_type1_notfound' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has one OPEN Notification for 60001
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 207 AND MSG_SEVERITY_CDE = 40
      --AND CHAR_VAL_TXT = 'The External Industry Classification for 'BRSTRTYP - CMAT::-' received from BRS  not found in the  ExternalIndustryClassification Table.'
      AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

  Scenario: TC_5: TRAN_TYPE2 not present in IDMV should ignore as STRIP_DOMAIN_FIELD is set on this field and BRS can add new values dynamically

    Given I assign "tc_5_equity_equity_tran_type2_notfound.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-2844-AUTOMATION'
    WHERE TRD_ID = '3204-2776_tran_type2_notfound' AND END_TMS IS NULL
    """

    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if EXTR was created with EXEC_TRN_CAT_SUB_TYP as null
    Then I expect value of column "EXTR_VALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS EXTR_VALID_COUNT FROM FT_T_EXTR WHERE EXEC_TRN_CAT_SUB_TYP IS NULL AND END_TMS IS NULL AND EXEC_TRD_ID IN
      (SELECT DISTINCT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE XREF_TBL_TYP = 'EXTR' AND TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}') WHERE R=1)))
      """

  Scenario: TC_6: Missing TOUCH_COUNT should raise exception

    Given I assign "tc_6_equity_equity_missing_touch_count.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    # Check if NTEL has one OPEN Notification for 60001
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60001 AND MSG_SEVERITY_CDE = 40
      AND CHAR_VAL_TXT = 'Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, TOUCH COUNT is not present in the input record.'
      AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """

  Scenario: TC_7: ORD_NUM Not Available in DMP should raise exception but should not fail the segment load

    Given I assign "tc_7_equity_equity_ord_num_not_avail_dmp.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I copy files below from local folder "${testdata.path}/infiles/0005" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I execute below query
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID, END_TMS = SYSDATE, LAST_CHG_USR_ID = LAST_CHG_USR_ID || 'TOM-4196-AUTOMATION'
    WHERE TRD_ID = '3204-999999_ORDNUM' AND END_TMS IS NULL
    """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

     # Check if NTEL has one OPEN Notification for 60001
    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60021
      AND CHAR_VAL_TXT = 'The Authorized Order for ''BRS_ORDER - 1007'' received from BRS  not found in the  AuthorizedOrder Table.'
      AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}')
      WHERE R=1))
      """