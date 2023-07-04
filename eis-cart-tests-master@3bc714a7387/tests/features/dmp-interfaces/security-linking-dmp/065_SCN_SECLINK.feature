@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_065
Feature: SCN65:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_065" to variable "testdata.path"

  Scenario: Prerequisites before running actual tests

    Given I assign "SCN_SECLINK__RDM_SEQ_1_065.csv" to variable "INPUT_FILENAME1"
    Given I assign "SCN_SECLINK__RDM_SEQ_2_065.csv" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CUSIP | RDM_CUSIP |
      | ISIN  | RDM_ISIN  |
      | SEDOL | RDM_SEDOL |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | RDM_ISIN2 |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RDM_CUSIP}','${RDM_ISIN}','${RDM_SEDOL}','${RDM_ISIN2}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${RDM_CUSIP}','${RDM_ISIN}','${RDM_SEDOL}','${RDM_ISIN2}'"

  Scenario: Change of ISIN from same or higher ranking vendor
  Old ISIN was End dated and New ISIN was created with Start_tms as sysdate.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CUSIP    | ISS_ID     |
      | CURRENCY | CURR_CODE  |
      | ISIN     | ISIN_CODE1 |

    Then I expect value of column "BRS_ISID_ISIN_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_ISIN_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'ISIN'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      AND ISS_ID = '${ISIN_CODE1}'
      """

    Then I execute below query
      """
      UPDATE FT_T_ISID
      SET START_TMS=SYSDATE-1
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL);
      COMMIT;
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISIN_CODE2 |

    Then I expect value of column "RDM_OLD_ISIN_UPDATE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_OLD_ISIN_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'ISIN'
      AND ISS_ID = '${ISIN_CODE1}'
      AND END_TMS IS NOT NULL
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "RDM_ISIN_UPDATE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_ISIN_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'ISIN'
      AND ISS_ID = '${ISIN_CODE2}'
      AND END_TMS IS NULL
      AND TRUNC(START_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

  Scenario: Delete ISIN_CODE as a prerequisite to clear the data

    And I set the database connection to configuration "dmp.db.GC"
    When I execute below query
      """
      DELETE FROM FT_T_ISID
      WHERE ISS_ID = '${ISIN_CODE1}'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ISS_ID}') AND END_TMS IS NULL);
      COMMIT;
      """

    And I set the database connection to configuration "dmp.db.VD"
    When I execute below query
      """
      DELETE FROM FT_T_ISID
      WHERE ISS_ID = '${ISIN_CODE1}'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ISS_ID}') AND END_TMS IS NULL);
      COMMIT;
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RDM_CUSIP}','${RDM_ISIN}','${RDM_SEDOL}','${RDM_ISIN2}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${RDM_CUSIP}','${RDM_ISIN}','${RDM_SEDOL}','${RDM_ISIN2}'"





