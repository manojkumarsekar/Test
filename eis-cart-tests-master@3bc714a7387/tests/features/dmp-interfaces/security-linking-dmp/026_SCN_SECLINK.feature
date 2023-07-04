@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_026 @tom_4434
Feature: SCN26:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_026" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__BNP_026.out" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_026.xml" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID    | ISS_ID     |
      | SEDOL       | BNP_SEDOL  |
      | HIP_EXT2_ID | BNP_BCUSIP |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP_SEDOL}'"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP_SEDOL}'"

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP_BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP_BCUSIP}'"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

  Scenario: TC_2: Verify security linking during BRS feed load for SEDOL
  Security update should happen correctly on the right security record in DMP

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      """

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
      SELECT * FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      """

    Then I expect value of column "BNP_MKID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
      AND A.MKT_ID_CTXT_TYP = 'MIC'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_ISID_MKT_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BNP_ISID_MKT_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_UPDATE_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_UPDATE_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_UPDATE_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_UPDATE_ISID_MKT1_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_MKT1_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
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
      """

    Then I expect value of column "BRS_UPDATE_ISID_SEDOL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_SEDOL_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'SEDOL'
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND ISS_ID = '${BNP_SEDOL}'
      """

    Then I expect value of column "BRS_UPDATE_MKT_OID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKT_OID_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND MKT_OID = '${MKT_OID}'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BNP_SEDOL}','${BNP_BCUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BNP_SEDOL}','${BNP_BCUSIP}'"
