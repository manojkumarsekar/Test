#EISDEV-6261 : This feature file tests security update between RDM and BNP. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_05
Feature: SCN05:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_05" to variable "testdata.path"
    And I assign "SCN_SECLINK__RDM_05.csv" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | ISS_ID    |
      | SEDOL | RDM_SEDOL |

    And I assign "SCN_SECLINK__BNP_NULL_05.out" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | BNP_INSTRID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BNP_INSTRID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BNP_INSTRID}'"

  Scenario: TC_1: Exception should be thrown in DMP through BNP feed load with Invalid Exchange as XX
  Exception will be raised and neither new market was created and nor old listing was updated on invalid exchange. BNP ids were created on old exchange.

    Given I assign "SCN_SECLINK__RDM_05.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_XX_05.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_NTEL_MKT_XX_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_NTEL_MKT_XX_COUNT FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT='User defined Error thrown! . PRIMARY EXCHAGE  is X or XX in the input record , please check'
      AND NTEL.NOTFCN_ID='60001'
      AND NTEL.SOURCE_ID like 'TRANSLATION'
      AND NTEL.MSG_TYP = 'EIS_MT_BNP_SECURITY'
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BNPLSTID'
      """

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISO_MIC | MKT_ID |

    And I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I expect value of column "BNP_UPDATE_MKT_MKID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      WHERE C.ISS_ID = '${ISS_ID}'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND A.MKT_ID='${MKT_ID}'
      """

  Scenario: TC_2: Exception should be thrown in DMP through BNP feed load with Invalid Exchange as X
  Exception will be raised and neither new market was created and nor old listing was updated on invalid exchange. BNP ids were created on old exchange.

    Given I assign "SCN_SECLINK__RDM_05.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_X_05.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_NTEL_MKT_X_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS BNP_NTEL_MKT_X_COUNT FROM FT_T_NTEL NTEL
        JOIN FT_T_TRID TRID
        ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
        WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
            TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
            JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
            TASK_CMPLTD_CNT > 0)
        AND NTEL.PARM_VAL_TXT='User defined Error thrown! . PRIMARY EXCHAGE  is X or XX in the input record , please check'
        AND NTEL.NOTFCN_ID='60001'
        AND NTEL.SOURCE_ID like 'TRANSLATION'
        AND NTEL.MSG_TYP = 'EIS_MT_BNP_SECURITY'
        AND NOTFCN_STAT_TYP = 'OPEN'
        AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BNPLSTID'
        """

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISO_MIC | MKT_ID |


    And I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "6":
        """
        SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
        JOIN FT_T_MKIS B
        ON A.MKT_OID=B.MKT_OID
        JOIN FT_T_ISID C
        ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
        WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
        """

    And I expect value of column "BNP_UPDATE_MKT_MKID_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS BNP_UPDATE_MKT_MKID_COUNT FROM FT_T_MKID A
        JOIN FT_T_MKIS B
        ON A.MKT_OID = B.MKT_OID
        AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
        JOIN FT_T_ISID C
        ON B.INSTR_ID = C.INSTR_ID
        WHERE C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL AND A.DATA_STAT_TYP='ACTIVE' AND A.MKT_ID='${MKT_ID}'
        """

  Scenario: TC_3: No Exception should be thrown in DMP through BNP feed load with NULL Exchange on Invalid RDM feed load (Without Exchange in the Feed)

    Given I assign "SCN_SECLINK__RDM_INVALID_05.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_NULL_05.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_NTEL_MKT_XX_COUNT" in the below SQL query equals to "0":
        """
        SELECT COUNT(*) AS BNP_NTEL_MKT_XX_COUNT FROM FT_T_NTEL NTEL
        JOIN FT_T_TRID TRID
        ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
        WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
            TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
            JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
            TASK_CMPLTD_CNT > 0)
        AND NTEL.MSG_TYP = 'EIS_MT_BNP_SECURITY'
        AND NOTFCN_STAT_TYP = 'OPEN'
        AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BNPLSTID'
        """

    And I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "6":
        """
        SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
        JOIN FT_T_MKIS B
        ON A.MKT_OID=B.MKT_OID
        JOIN FT_T_ISID C
        ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
        WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
        """

  @ignore
  Scenario: TC_4: Exception should be thrown in DMP through BNP feed load with NULL Exchange on Valid RDM Feed (Valid Exchange)

    Given I assign "SCN_SECLINK__RDM_05.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_NULL_05.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    And I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_NTEL_INVLD_MKT_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_NTEL_INVLD_MKT_COUNT FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%${INPUT_FILENAME2}' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT='Market update was not allowed as Market in Database has a valid MKT_ID = ''XHKG'' with MKT_ID_CTXT_TYP ''MIC'' and market coming in feed is of dummy market with MKT_ID = ''ZZZZ'''
      AND NTEL.NOTFCN_ID='60009'
      AND NTEL.SOURCE_ID like '%_GC%'
      AND NTEL.MSG_TYP = 'EIS_MT_BNP_SECURITY'
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BNPLSTID'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BNP_INSTRID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${BNP_INSTRID}'"