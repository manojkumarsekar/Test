@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_058
Feature: SCN58: Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_058" to variable "testdata.path"
    And I assign "SCN_SECLINK__RDM_058.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_058.xml" to variable "INPUT_FILENAME2"
    And I assign "SCN_SECLINK__BNP_058.out" to variable "INPUT_FILENAME3"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | ISS_ID    |
      | SEDOL | RDM_SEDOL |

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "BRS_CUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "BRS_SEDOL"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME3}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | BNP_INSTRID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BRS_CUSIP}','${BRS_SEDOL}','${BNP_INSTRID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BRS_CUSIP}','${BRS_SEDOL}','${BNP_INSTRID}'"

  Scenario: TC_1: Verify security linking during RDM feed load for ISIN with CURRENCY pair MATCHING with Multiple records in DMP with available data in DMP and SEDOL missing
  More than 1 listing present the it will raise fatal exception and rejects whole record.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "13":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME3}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "13":
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
        JOB_INPUT_TXT LIKE '%${INPUT_FILENAME3}' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT LIKE '%Multiple listing found for same instr_id%and trading currency%'
    AND NTEL.NOTFCN_ID = '60003'
    AND NTEL.SOURCE_ID LIKE '%_GC%'
    AND NTEL.CHAR_VAL_TXT LIKE '%Data validation failed in Input file Multiple listing found for same instr_id%and trading currency%'
    AND NTEL.MSG_TYP = 'EIS_MT_BNP_SECURITY'
    AND MSG_SEVERITY_CDE = 50
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BNPLSTID'
    AND NTEL.MAIN_ENTITY_ID = '${BNP_INSTRID}'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BRS_CUSIP}','${BRS_SEDOL}','${BNP_INSTRID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BRS_CUSIP}','${BRS_SEDOL}','${BNP_INSTRID}'"
