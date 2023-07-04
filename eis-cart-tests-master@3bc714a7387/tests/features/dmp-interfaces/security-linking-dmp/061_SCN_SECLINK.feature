#EISDEV-6261 : This feature file tests security update between RDM and BRS. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@dmp_regression_unittest
@dmp_securities_linking @sec_link_061 @ignore
Feature: SCN61: Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_061" to variable "testdata.path"
    And I assign "SCN_SECLINK__BRS_061.xml" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__RDM_061.csv" to variable "INPUT_FILENAME2"

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with tagName "CUSIP" to variable "ISS_ID"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

  Scenario: TC_1:Verify security linking during RDM feed load for ISIN and SEDOL unavailable, CUSIP matching, CUSIP + CURRENCY NOT matching..
  As ISIN and SEDOL are not available It wil check if cusip+ccy matches update listing and create listing and raise warning if CURRENCY not matching.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with tagName "CURRENCY" to variable "BRS_CCY"

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND TRDNG_CURR_CDE = '${BRS_CCY}'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CUSIP     | RDM_CUSIP |
      | CURRENCY  | RDM_CCY   |
      | CLIENT_ID | RDM_ID    |

    Then I expect value of column "RDM_MKIS_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS RDM_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND TRDNG_CURR_CDE IN ('${RDM_CCY}','${BRS_CCY}')
      """

    Then I expect value of column "RDM_NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_NTEL_COUNT FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID = (SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT LIKE 'CUSIP%${RDM_CUSIP}, CURRENCY%${RDM_CCY} not found in DB. Hence creating listing%'
      AND NTEL.NOTFCN_ID='60011'
      AND NTEL.SOURCE_ID LIKE '%_GC%'
      AND NTEL.MSG_TYP = 'EIS_MT_RDM_EOD_SECURITY'
      AND MSG_SEVERITY_CDE = 30
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'RDMID'
      AND NTEL.MAIN_ENTITY_ID='${RDM_ID}'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
