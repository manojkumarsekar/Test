@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_015 @tom_4434
Feature: SCN15:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_015" to variable "testdata.path"
    And I assign "SCN_SECLINK__RDM_015.csv" to variable "INPUT_FILENAME1"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | ISS_ID    |
      | SEDOL | RDM_SEDOL |

    And I assign "SCN_SECLINK__BRS_015.xml" to variable "INPUT_FILENAME2"

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "CUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "BRS_SEDOL"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${CUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BRS_SEDOL}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BRS_SEDOL}'"

  Scenario: TC_1:Verify security linking during RDM feed load for ISIN with CURRENCY pair MATCHING with available data in DMP and SEDOL available
  New Listings should create.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_ISID_MKT_COUNT" in the below SQL query equals to "4":
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

    Then I expect value of column "BRS_UPDATE_ISID_COUNT" in the below SQL query equals to "13":
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

    Then I expect value of column "BRS_UPDATE_ISID_MKT1_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_MKT1_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_ISID_MKT2_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_MKT2_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_MKIS_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_UPDATE_MKID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.MKT_ID_CTXT_TYP = 'INHOUSE'
      WHERE C.ISS_ID='${ISS_ID}'
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

    Then I expect value of column "BRS_UPDATE_ISID_SEDOL_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_SEDOL_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'SEDOL'
      AND ISS_ID IN ('${RDM_SEDOL}','${BRS_SEDOL}')
      """

  Scenario: Clear the data after tests
   Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${CUSIP}','${BRS_SEDOL}'"
   Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${CUSIP}','${BRS_SEDOL}'"