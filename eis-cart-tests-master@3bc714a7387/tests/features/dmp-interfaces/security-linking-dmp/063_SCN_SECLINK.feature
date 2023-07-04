#New Scenario

@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_063 @tom_4434
Feature: SCN63: Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_063" to variable "testdata.path"
    And I assign "SCN_SECLINK__BRS_063.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "ISS_ID"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"

    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BCUSIP}'"

  Scenario: TC_1: Verify security and listing creation during BRS feed load for ISIN being unavailable, SEDOL available (New Security)
  Raise warning and create listing.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      """

    Then I expect value of column "BRS_MKID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
      AND A.MKT_ID_CTXT_TYP = 'ALADDIN'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_ISID_MKT_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_ISID_MKT_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
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
    AND NTEL.PARM_VAL_TXT LIKE 'ISIN not available in the message, ${ISS_ID}SEDOL available in message. Hence creating listing%'
    AND NTEL.NOTFCN_ID = '60011'
    AND NTEL.SOURCE_ID LIKE '%_GC%'
    AND NTEL.MSG_TYP = 'EIS_MT_BRS_SECURITY_NEW'
    AND MSG_SEVERITY_CDE = 30
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BCUSIP'
    AND NTEL.MAIN_ENTITY_ID = '${BCUSIP}'
    """

  Scenario: Clear the data after tests
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BCUSIP}'"


