#EISDEV-6261 : This feature file tests security update between RDM and BRS. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@dmp_regression_unittest
@dmp_securities_linking @sec_link_066 @ignore
Feature: SCN66:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_066" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "SCN_SECLINK__RDM_066.csv" to variable "INPUT_FILENAME2"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID2 |

    Given I assign "SCN_SECLINK__BRS_066.xml" to variable "INPUT_FILENAME1"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with tagName "CUSIP" to variable "ISS_ID"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "SEDOL"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID2}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID2}'"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${SEDOL}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${SEDOL}'"

  Scenario: TC_2:Change of ISIN from lower ranking vendor

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with tagName "CURRENCY" to variable "CURR_CODE"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with xpath "//CUSIP2_set//CODE[text()='I']/../IDENTIFIER" to variable "ISIN_CODE1"

    Then I expect value of column "BRS_ISID_ISIN_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_ISIN_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'ISIN'
      AND ISS_ID = '${ISIN_CODE1}'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISIN_CODE2 |

    Then I expect value of column "RDM_OLD_ISIN_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS RDM_OLD_ISIN_COUNT FROM FT_T_ISID
        WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND ID_CTXT_TYP = 'ISIN'
        AND ISS_ID = '${ISIN_CODE1}'
        AND END_TMS IS NULL
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
        """

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "9":
        """
        SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
        WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
        """

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
        WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
        """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${ISS_ID2}','${SEDOL}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${ISS_ID2}','${SEDOL}'"



