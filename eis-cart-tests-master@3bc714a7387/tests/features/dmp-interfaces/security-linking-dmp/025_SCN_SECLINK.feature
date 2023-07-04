@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_025
Feature: SCN25:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_025" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__BNP_1_025.out" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BNP_2_025.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Security load from BNP file with incorrect HIP_EXT2_ID value
  Exception should be thrown and record should get rejected.

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | HIP_EXT2_ID | HIPEXT2ID_CODE1 |

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    """

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ID_CTXT_TYP = 'HIPEXT2ID'
    AND ISS_ID = '${HIPEXT2ID_CODE1}'
    """

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ID_CTXT_TYP = 'BCUSIP'
    AND ISS_ID = '${HIPEXT2ID_CODE1}'
    """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | HIP_EXT2_ID | HIPEXT2ID_CODE2 |
      | INSTR_ID    | BNP_CODE        |

    Then I expect value of column "BNP_ISID_UPDATE_COUNT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS BNP_ISID_UPDATE_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    """

    Then I expect value of column "BNP_ISID_UPDATE_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_ISID_UPDATE_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ID_CTXT_TYP = 'HIPEXT2ID'
    AND ISS_ID = '${HIPEXT2ID_CODE1}'
    """

    Then I expect value of column "BNP_ISID_UPDATE_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BNP_ISID_UPDATE_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ID_CTXT_TYP = 'HIPEXT2ID'
    AND ISS_ID = '${HIPEXT2ID_CODE2}'
    """

    Then I expect value of column "BNP_ISID_UPDATE_BCUSIP_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_ISID_UPDATE_BCUSIP_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ID_CTXT_TYP = 'BCUSIP'
    """

    Then I expect value of column "BNP_ISID_UPDATE_BCUSIP_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_ISID_UPDATE_BCUSIP_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ID_CTXT_TYP = 'BCUSIP'
    AND ISS_ID = '${HIPEXT2ID_CODE1}'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
