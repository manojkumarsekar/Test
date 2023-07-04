#IT COVERS old SCN 49 TO 64
#New Scenarios numbers
#SCN 40 to SCN 55
#SCN 33 AS WELL
#SCN 62 AS WELL
#https://jira.pruconnect.net/browse/EISDEV-7224
#EXM Rel 7 - Removing scenarios for exception validations with non mandatory INSTR_ID (BNP MD_ID)

@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_040 @eisdev_7224
Feature: SCN40_SCN55:Security Linking Criteria: Data Management Platform (Golden Source)
  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_040" to variable "testdata.path"

  Scenario Outline: TC_1: Prerequisite Scenario for instrument type <InstrType>
    Given I assign "SCN_SECLINK_40To55_BNP.out" to variable "INPUT_FILENAME"

    And I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

    Examples:
      | InstrType  | RowNum |
      | CCCPCTA    | 2      |
      | CCCPIMG    | 3      |
      | CCCPVMG    | 4      |
      | CDEPCAL    | 5      |
      | CDEPFIX    | 6      |
      | CLONLON    | 7      |
      | CMEMMEM    | 8      |
      | ICURREV    | 9      |
      | CDEPNOT    | 10     |
      | BMMFXXXXFU | 11     |
      | BMRCXXXXSU | 12     |
      | BMMFXXXXNU | 13     |
      | CCOLCOL    | 14     |
      | CCURCUR    | 15     |
      | CFUTIMG    | 16     |
      | CFUTVMG    | 17     |
      | BDYFXXXXBU | 18     |

  Scenario: TC_2: Load BNP Feed with multiple Instruments

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

  Scenario Outline: TC_3: Validate DMP creating securities when the instrument type <InstrType>

    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | BNPLSTID |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "3":
        """
        SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
        WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNPLSTID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
        """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS BNP_MKIS_COUNT
        FROM FT_T_MKIS
        WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNPLSTID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        """

    Then I expect value of column "BNP_ISID_BNPLSTID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS BNP_ISID_BNPLSTID_COUNT FROM FT_T_ISID
        WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNPLSTID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND ID_CTXT_TYP='BNPLSTID'
        AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
        AND ISS_ID = '${BNPLSTID}'
        AND MKT_OID IS NOT NULL
        """

    Examples:
      | InstrType  | RowNum |
      | CCCPCTA    | 2      |
      | CCCPIMG    | 3      |
      | CCCPVMG    | 4      |
      | CDEPCAL    | 5      |
      | CDEPFIX    | 6      |
      | CLONLON    | 7      |
      | CMEMMEM    | 8      |
      | ICURREV    | 9      |
      | CDEPNOT    | 10     |
      | BMMFXXXXFU | 11     |
      | BMRCXXXXSU | 12     |
      | BMMFXXXXNU | 13     |

  Scenario Outline: TC_4: Validate DMP creating securities when the instrument type <InstrType>

    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | BNPLSTID |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNPLSTID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNPLSTID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_ISID_BNPLSTID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_ISID_BNPLSTID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BNPLSTID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='BNPLSTID'
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      AND ISS_ID = '${BNPLSTID}'
      AND MKT_OID IS NOT NULL
      """

    Examples:
      | InstrType | RowNum |
      | CCOLCOL   | 14     |
      | CCURCUR   | 15     |
      | CFUTIMG   | 16     |
      | CFUTVMG   | 17     |

  Scenario: TC_5: Security record in the file is missing public identifiers (ISIN, CUSIP, and SEDOL) AND missing HIP_EXT2_ID and the instrument type is "CDEPNOT".
  Security will be created successfully.

    Given I assign "SCN_SECLINK_62_BNP.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_ISID_BNPLSTID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_ISID_BNPLSTID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='BNPLSTID'
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      AND ISS_ID = '${ISS_ID}'
      AND MKT_OID IS NOT NULL
      """