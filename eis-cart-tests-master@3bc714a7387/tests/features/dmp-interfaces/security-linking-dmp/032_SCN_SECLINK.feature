@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_032
Feature: SCN32:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_032" to variable "testdata.path"
    And I assign "SCN_SECLINK__BNP_032.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID    | ISS_ID      |
      | HIP_EXT2_ID | HIP_EXT2_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

  Scenario: TC_1:Security load from BNP file with HIP_EXT2_ID is less than mandatory 9 characters.
  when HIP_EXT2_ID not equal to 9 characters, Do not store the HIP_EXT2_ID in DMP, however all other data point fields should get stored for the record

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_NO_BCUSIP_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BNP_ISID_NO_BCUSIP_COUNT FROM FT_T_ISID
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP = 'BCUSIP'
    AND ISS_ID = '${HIP_EXT2_ID}'
    """

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP = 'HIPEXT2ID'
    AND ISS_ID = '${HIP_EXT2_ID}'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
