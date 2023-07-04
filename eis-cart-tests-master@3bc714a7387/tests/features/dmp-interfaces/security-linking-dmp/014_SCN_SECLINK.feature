#EISDEV-6261 : This feature file tests security update between RDM and BRS. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_014 @ignore
Feature: SCN14:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_014" to variable "testdata.path"
    And I assign "SCN_SECLINK__BRS_014.xml" to variable "INPUT_FILENAME"

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "ISS_ID"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "IDENTIFIER" to variable "BRS_ISIN_CODE"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BRS_ISIN_CODE}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BRS_ISIN_CODE}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'BMO'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BMO'"

  Scenario: TC_1:Verify security linking during RDM feed load for ISIN with CURRENCY pair MATCHING with available data in DMP When SEDOL missing
  Security update should happen correctly on the right security record in DMP

    Given I assign "SCN_SECLINK__BRS_014.xml" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__RDM_014.csv" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "IDENTIFIER" to variable "BRS_ISIN_CODE"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID | RDMID_CODE    |
      | ISIN      | RDM_ISIN_CODE |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='ISIN'
      AND ISS_ID = '${BRS_ISIN_CODE}'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I expect value of column "RDM_UPDATE_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS RDM_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_CUSIP_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_CUSIP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='ISIN'
      AND ISS_ID = '${BRS_ISIN_CODE}'
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "RDM_RDMID_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_RDMID_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='RDMID'
      AND ISS_ID = '${RDMID_CODE}'
      AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "RDM_NTEL_WARN_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_NTEL_WARN_COUNT FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT LIKE 'ISIN%CURRENCY%found in DB and SEDOL not available in message. Hence updating listing%'
      AND NTEL.NOTFCN_ID='60010'
      AND NTEL.SOURCE_ID like '%_GC%'
      AND NTEL.MSG_TYP = 'EIS_MT_RDM_EOD_SECURITY'
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'RDMID'
      """

  Scenario: Clear the data after tests

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BRS_ISIN_CODE}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BRS_ISIN_CODE}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'BMO'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BMO'"
