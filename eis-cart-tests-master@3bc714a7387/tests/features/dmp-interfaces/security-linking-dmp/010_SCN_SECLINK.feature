#EISDEV-6261 : This feature file tests security update between RDM and BNP. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_010 @ignore
Feature: SCN10: Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_010" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "SEC_SECLINK__BNP_SEQ1_010.out" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__RDM_010.csv" to variable "INPUT_FILENAME2"
    And I assign "SCN_SECLINK__BNP_SEQ2_010.out" to variable "INPUT_FILENAME3"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | ISIN  | BNP1_ISIN  |
      | SEDOL | BNP1_SEDOL |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | RDM_ISIN  |
      | SEDOL | RDM_SEDOL |

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME3}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | ISIN        | BNP2_ISIN   |
      | SEDOL       | BNP2_SEDOL  |
      | HIP_EXT2_ID | BNP2_BCUSIP |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP1_ISIN}','${BNP1_SEDOL}','${RDM_ISIN}','${RDM_SEDOL}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP1_ISIN}','${BNP1_SEDOL}','${RDM_ISIN}','${RDM_SEDOL}'"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP2_ISIN}','${BNP2_SEDOL}','${BNP2_BCUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP2_ISIN}','${BNP2_SEDOL}','${BNP2_BCUSIP}'"

  Scenario: TC_2:Validate all listing level IDs once match is found. When identifier is found matched however there is another listing attached on the next ID in hierarchy
  Since BNP is high ranker vendor than RDM, ISIN will be updated, market will be updated successfully.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_ISID_UPDATE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_ISID_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'RDMID'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "RDM_ISID_UPDATE_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS RDM_ISID_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP IN ('ISIN','SEDOL')
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      """

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
      SELECT * FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME3}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |


    #All records will be updated by BNP
    Then I expect value of column "BNP_ISID_UPDATE_COUNT" in the below SQL query equals to "9":
      """
      SELECT COUNT(*) AS BNP_ISID_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_ISID_ISIN_UPDATE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_ISID_ISIN_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'ISIN'
      AND ISS_ID = '${BNP2_ISIN}'
      """

    Then I expect value of column "BNP_ISID_SEDOL_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BNP_ISID_SEDOL_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      AND ID_CTXT_TYP = 'SEDOL'
      AND ISS_ID IN ('${BNP1_SEDOL}','${BNP2_SEDOL}')
      """

    #After Loading BRS feed MKT_OID should be updated, hence no rows with old MKT_OID
    Then I expect value of column "BNP_MKIS_MKT_OID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS BNP_MKIS_MKT_OID_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNP1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      AND MKT_OID = '${MKT_OID}'
      """

    And I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${BNP1_SEDOL}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

  Scenario: Cleaning data after Tests

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP1_ISIN}','${BNP1_SEDOL}','${RDM_ISIN}','${RDM_SEDOL}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP1_ISIN}','${BNP1_SEDOL}','${RDM_ISIN}','${RDM_SEDOL}'"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP2_ISIN}','${BNP2_SEDOL}','${BNP2_BCUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP2_ISIN}','${BNP2_SEDOL}','${BNP2_BCUSIP}'"
