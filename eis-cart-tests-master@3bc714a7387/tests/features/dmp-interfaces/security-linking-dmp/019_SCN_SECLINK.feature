#New Scenario
@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_019 @tom_4434
Feature: SCN19:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_019" to variable "testdata.path"
    And I assign "SCN_SECLINK__RDM_019.csv" to variable "INPUT_FILENAME1"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | ISS_ID    |
      | CUSIP | RDM_CUSIP |

    And I assign "SCN_SECLINK__BRS_019.xml" to variable "INPUT_FILENAME2"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "BRS_CUSIP"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CURRENCY" to variable "BRS_CURRENCY"

    Then I inactivate "${ISS_ID},${BRS_CUSIP},${RDM_CUSIP}" instruments in VD database
    And I inactivate "${ISS_ID},${BRS_CUSIP},${RDM_CUSIP}" instruments in GC database

  Scenario: TC_1: Verify security linking during RDM feed load for ISIN with CURRENCY pair NOT-MATCHING with available data in DMP + SEDOL unavailable. CUSIP available and CUSIP+CCY unmacthed
  Raise warning and create listing

    When I copy below files into dmp inbound folder
      | ${testdata.path}/data-feeds/${INPUT_FILENAME1} |
      | ${testdata.path}/data-feeds/${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_ISID_MKT_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS RDM_ISID_MKT_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "RDM_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      """

    Then I expect value of column "RDM_MKID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS RDM_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
      AND A.MKT_ID_CTXT_TYP = 'INHOUSE'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    And I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "BRS_UPDATE_ISID_COUNT" in the below SQL query equals to "11":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_UPDATE_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_MKIS_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_UPDATE_ISID_MKT1_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_MKT1_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID = C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_ISID_MKT2_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_MKT2_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_MKID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
      AND A.MKT_ID_CTXT_TYP = 'INHOUSE'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_MKID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKID_COUNT FROM FT_T_MKID A
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


    Then I expect value of column "BRS_UPDATE_ISID_SEDOL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_SEDOL_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'CUSIP'
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND ISS_ID = '${RDM_CUSIP}'
      """

    Then I expect an exception is captured with the following criteria
      | PARM_VAL_TXT            | CUSIP%${RDM_CUSIP}, CURRENCY%${BRS_CURRENCY} not found in DB. Hence creating listing% |
      | NOTFCN_ID               | 60011                                                                                 |
      | SOURCE_ID               | %_GC%                                                                                 |
      | MSG_TYP                 | EIS_MT_BRS_SECURITY_NEW                                                               |
      | NOTFCN_STAT_TYP         | OPEN                                                                                  |
      | MAIN_ENTITY_ID_CTXT_TYP | BCUSIP                                                                                |
      | MAIN_ENTITY_ID          | ${BRS_CUSIP}                                                                          |
      | MSG_SEVERITY_CDE        | 30                                                                                    |

  Scenario: Clear the data after tests

    Then I inactivate "${ISS_ID},${BRS_CUSIP},${RDM_CUSIP}" instruments in GC database
    And I inactivate "${ISS_ID},${BRS_CUSIP},${RDM_CUSIP}" instruments in VD database
