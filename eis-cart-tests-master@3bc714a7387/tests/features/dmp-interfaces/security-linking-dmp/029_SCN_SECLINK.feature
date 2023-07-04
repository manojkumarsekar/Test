@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_029 @tom_4434
Feature: SCN29:Security Linking Criteria: Data Management Platform (Golden Source)
    Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_029" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__BNP_029.out" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_029.xml" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID      | ISS_ID      |
      | HIP_EXT2_ID   | BNP_BCUSIP  |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP_BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP_BCUSIP}'"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      |${INPUT_FILENAME1}|
      |${INPUT_FILENAME2}|

  Scenario: TC_2: Verify security linking during BRS feed load for BCUSIP
      Security update should happen correctly on the right security record in DMP. Linking should be based on the HIP_EXT2_ID (i.e., BCUSIP) against the BCUSIP stored in the DMP.

    And I process files with below parameters and wait for the job to be completed
      |  FILE_PATTERN | ${INPUT_FILENAME1}      |
      |  MESSAGE_TYPE | EIS_MT_BNP_SECURITY     |
      |  BUSINESS_FEED|                         |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_ISID_BCUSIP_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BNP_ISID_BCUSIP_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP IN ('BCUSIP','HIPEXT2ID')
      AND ISS_ID = '${BNP_BCUSIP}'
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
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

    Then I expect value of column "BNP_ISID_MKT_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BNP_ISID_MKT_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      |  FILE_PATTERN | ${INPUT_FILENAME2}      |
      |  MESSAGE_TYPE | EIS_MT_BRS_SECURITY_NEW |
      |  BUSINESS_FEED|                         |

    Then I expect value of column "BRS_UPDATE_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BRS_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_ISID_UPDATE_BCUSIP_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_ISID_UPDATE_BCUSIP_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP IN ('BCUSIP','HIPEXT2ID')
      AND ISS_ID = '${BNP_BCUSIP}'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
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
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
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

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BNP_BCUSIP}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BNP_BCUSIP}'"