@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_060 @tom_4434
Feature: SCN60:Security Linking Criteria: Data Management Platform (Golden Source)
  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_060" to variable "testdata.path"
    And I assign "SCN_SECLINK__RDM_060.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_NULL_EXG_060.xml" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | ISS_ID    |
      | SEDOL | RDM_SEDOL |

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "BCUSIP"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BCUSIP}'"

  Scenario: TC_1: Exception should be thrown in DMP through BRS feed load with NULL Exchange on Valid RDM Feed (Valid Exchange)

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
      SELECT * FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |


    And I expect value of column "BRS_UPDATE_MKT_MKID_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS BRS_UPDATE_MKT_MKID_COUNT FROM FT_T_MKID A
    JOIN FT_T_MKIS B
    ON A.MKT_OID = B.MKT_OID
    AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
    JOIN FT_T_ISID C
    ON B.INSTR_ID = C.INSTR_ID
    WHERE C.ISS_ID = '${ISS_ID}'
    AND A.MKT_ID_CTXT_TYP = 'ALADDIN'
    AND C.END_TMS IS NULL
    AND A.DATA_STAT_TYP='ACTIVE'
    """

    And I expect value of column "BRS_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS BRS_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
    JOIN FT_T_MKIS B
    ON A.MKT_OID=B.MKT_OID
    JOIN FT_T_ISID C
    ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
    WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "BRS_MKIS_MKT_OID_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_MKIS_MKT_OID_COUNT FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND MKT_OID = '${MKT_OID}'
    """

    Then I expect value of column "BRS_NTEL_INVLD_MKT_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_NTEL_INVLD_MKT_COUNT FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT='Market update was not allowed as Market in Database has a valid MKT_ID = ''XIDX'' with MKT_ID_CTXT_TYP ''MIC'' and market coming in feed is of dummy market with MKT_ID = ''ZZZZ'''
      AND NTEL.NOTFCN_ID='60009'
      AND NTEL.SOURCE_ID like '%_GC%'
      AND NTEL.MSG_TYP = 'EIS_MT_BRS_SECURITY_NEW'
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BCUSIP'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BCUSIP}'"