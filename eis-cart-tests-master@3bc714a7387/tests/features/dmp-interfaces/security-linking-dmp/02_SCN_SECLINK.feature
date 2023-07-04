@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_02
Feature: SCN02:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_02" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "SCN_SECLINK__RDM_02.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:RDM feed for a new Security without CURRENCY field, Exception should be thrown
  As per RDM methodology, System should raise exception and Reject the record when CURRENCY is missing the data feed
  New Security should not be created.

    Given I assign "SCN_SECLINK__RDM_02.csv" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID | RDMID |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "RDM_NTEL_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RDM_NTEL_COUNT FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='User defined Error thrown! . Cannot process record as required fields, CURRENCY is not present in the input record.'
    AND NTEL.NOTFCN_ID='60001'
    AND NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process record as required fields, CURRENCY is not present in the input record%'
    AND NTEL.MSG_TYP = 'EIS_MT_RDM_EOD_SECURITY'
    AND MSG_SEVERITY_CDE=40
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'RDMID'
    AND NTEL.MAIN_ENTITY_ID='${RDMID}'
    """

    Then I expect value of column "RDM_MKIS_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RDM_MKIS_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "RDM_MKID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RDM_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
        ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
        ON B.INSTR_ID = C.INSTR_ID
        AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
        AND C.END_TMS IS NULL
    """

  Scenario: TC_3:BRS Feed for a new Security without CURRENCY field, Exception should be thrown
  As per BRS methodology, System should raise exception and Reject the record when CURRENCY is missing the data feed.
  New Security should not be created.

    Given I assign "SCN_SECLINK__BRS_02.xml" to variable "INPUT_FILENAME"

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "BRS_NTEL_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_NTEL_COUNT FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='User defined Error thrown! . Cannot process record as required fields, CURRENCY is not present in the input record.'
    AND NTEL.NOTFCN_ID='60001'
    AND NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process record as required fields, CURRENCY is not present in the input record%'
    AND NTEL.MSG_TYP = 'EIS_MT_BRS_SECURITY_NEW'
    AND MSG_SEVERITY_CDE=40
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BCUSIP'
    AND NTEL.MAIN_ENTITY_ID='${BCUSIP}'
    """

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BRS_MKIS_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "BRS_MKID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BRS_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
        ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
        ON B.INSTR_ID = C.INSTR_ID
        AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
        AND C.END_TMS IS NULL
    """

  Scenario: TC_4:BNP Feed for a new Security without CURRENCY field, Exception should be thrown
  As per BNP methodology, System should raise exception and Reject the record when CURRENCY is missing the data feed. New Security should not be created.

    Given I assign "SCN_SECLINK__BNP_02.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | BNPLSTID |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "BNP_NTEL_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_NTEL_COUNT FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='User defined Error thrown! . Cannot process record as required fields, ISSUE_CCY, CUSIP, HIP_EXT2_ID is not present in the input record.'
    AND NTEL.NOTFCN_ID='60001'
    AND NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process record as required fields, ISSUE_CCY, CUSIP, HIP_EXT2_ID is not present in the input record%'
    AND NTEL.MSG_TYP = 'EIS_MT_BNP_SECURITY'
    AND MSG_SEVERITY_CDE=40
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BNPLSTID'
    AND NTEL.MAIN_ENTITY_ID='${BNPLSTID}'
    """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BNP_MKIS_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "BNP_MKID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BNP_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
        ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
        ON B.INSTR_ID = C.INSTR_ID
        AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
        AND C.END_TMS IS NULL
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

