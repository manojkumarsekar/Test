@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_021
Feature: SCN21:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_021" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__RDM_021.csv" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify the security creation scenarios when none filter criteria matches
  Security should get created successfully. With a single listing only.

    Given I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_RDMID_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RDM_ISID_RDMID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND DATA_SRC_ID = 'EIS'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    AND ID_CTXT_TYP = 'RDMID'
    AND ISS_ID = '${ISS_ID}'
    """

    Then I expect value of column "RDM_ISID_MKT_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RDM_ISID_MKT_COUNT FROM FT_T_ISID A
    JOIN FT_T_MKIS B
    ON A.MKT_OID=B.MKT_OID
    JOIN FT_T_ISID C
    ON A.INSTR_ID=C.INSTR_ID AND B.INSTR_ID=C.INSTR_ID AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
    WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND DATA_SRC_ID = 'EIS'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
