#EISDEV-6261 : This feature file tests security update between RDM and BNP. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@dmp_regression_unittest
@dmp_securities_linking @sec_link_023 @ignore
Feature: SCN23:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_023" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__RDM_023.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BNP_023.out" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify security linking during BNP feed load for SEDOL (CURRENCY is different)
  Security update should happen correctly on the right security record in DMP

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CURRENCY | RDM_CCY_CODE |

    Then I expect value of column "RDM_ISID_CCY_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RDM_ISID_CCY_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP IN ('EISLSTID','RDMID')
    AND TRDNG_CURR_CDE = '${RDM_CCY_CODE}'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

    Then I expect value of column "RDM_MKIS_CCY_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RDM_MKIS_CCY_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND TRDNG_CURR_CDE = '${RDM_CCY_CODE}'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_UPDATE_COUNT" in the below SQL query equals to "9":
    """
    SELECT COUNT(*) AS BNP_ISID_UPDATE_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "BNP_ISID_UPDATE_COUNT" in the below SQL query equals to "8":
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
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | ISSUE_CCY | BNP_CCY_CODE |

    Then I expect value of column "BNP_MKIS_UPDATE_CCY_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_MKIS_UPDATE_CCY_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND TRDNG_CURR_CDE = '${BNP_CCY_CODE}'
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    """

    #As discussed with Anand, below verification is not valid, so commenting
    #Then I expect value of column "BNP_ISID_UPDATE_CCY_COUNT" in the below SQL query equals to "2":
    #"""
    #SELECT COUNT(*) AS BNP_ISID_UPDATE_CCY_COUNT FROM FT_T_ISID
    #WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    #AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    #AND ID_CTXT_TYP IN ('EISLSTID','RDMID')
    #AND TRDNG_CURR_CDE = '${BNP_CCY_CODE}'
    #AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    #"""

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"





