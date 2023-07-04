#EISDEV-6261 : This feature file tests security update between RDM and BNP. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@dmp_regression_unittest
@dmp_securities_linking @sec_link_022 @ignore
Feature: SCN22:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_022" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__RDM_022.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BNP_022.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | SEDOL | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify security linking during BNP feed load having SEDOL.
  Security update should happen correctly on the right security record in DMP.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    And I expect value of column "BNP_UPDATE_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS BNP_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I expect value of column "BNP_UPDATE_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BNP_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      """

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | PRIMARY_EXCHANGE | MKT_CODE |

    And I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    And I expect value of column "BNP_UPDATE_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
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
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      AND A.MKT_ID_CTXT_TYP = 'MIC'
      AND A.MKT_ID = '${MKT_CODE}'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
