@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_020
Feature: SCN20:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_020" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario

    Given I assign "SCN_SECLINK__RDM_TWD_020.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__RDM_USD_020.csv" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN      | ISS_ID    |
      | SEDOL     | RDM_SEDOL |
      | CLIENT_ID | RDM_ID    |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${RDM_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${RDM_ID}'"

  Scenario: TC_2:Verify security linking during RDM feed load for SEDOL (CURRENCY is different)
  Currency will be updated.

    Given I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND DATA_SRC_ID = 'EIS'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CURRENCY | CURR_CODE |

    Then I expect value of column "RDM_ISID_UPDATE_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS RDM_ISID_UPDATE_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND DATA_SRC_ID = 'EIS'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
    """

    Then I expect value of column "RDM_ISID_CURRENCY_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RDM_ISID_CURRENCY_COUNT FROM FT_T_ISID
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP ='TICKER'
    AND TRDNG_CURR_CDE = '${CURR_CODE}'
    """

  Scenario: TC_3:Verify Data in FT_T_ISID

    Given I export below sql query results to CSV file "${testdata.path}/data-compare/Actual_FT_T_ISID_Data.csv"
    """
    SELECT ID_CTXT_TYP,ISS_ID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,GLOBAL_UNIQ_IND,LAST_CHG_USR_ID FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP NOT IN ('EISLSTID','EISSECID')
    ORDER BY LAST_CHG_TMS
    """

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/data-compare/Actual_FT_T_ISID_Data.csv" and reference CSV file "${testdata.path}/data-compare/Expected_FT_T_ISID_Data.csv" should be successful and exceptions to be written to "${testdata.path}/data-compare/FT_T_ISID_exceptions_${recon.timestamp}.csv" file

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${RDM_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${RDM_SEDOL}','${RDM_ID}'"




