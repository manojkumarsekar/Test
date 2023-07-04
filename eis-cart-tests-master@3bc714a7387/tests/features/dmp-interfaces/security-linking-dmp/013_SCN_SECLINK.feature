#EISDEV-6261 : This feature file tests security update between RDM and BRS. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_013 @ignore
Feature: SCN13:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_013" to variable "testdata.path"

    And I assign "SCN_SECLINK__BRS_013.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "ISS_ID"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'BMO'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BMO'"

  Scenario: TC_1:Verify security linking during RDM feed load for ISIN and SEDOL unavailable, CUSIP matching, CUSIP+CURRENCY matching..
  As ISIN and SEDOL are not available, cusip+ccy matches update listing.

    Given I assign "SCN_SECLINK__BRS_013.xml" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__RDM_013.csv" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "CUSIP_CODE"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID | RDMID_CODE |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='CUSIP'
      AND ISS_ID = '${CUSIP_CODE}'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I expect value of column "RDM_UPDATE_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS RDM_UPDATE_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_CUSIP_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_CUSIP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='CUSIP'
      AND ISS_ID = '${CUSIP_CODE}'
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "RDM_RDMID_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_RDMID_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='RDMID'
      AND ISS_ID = '${RDMID_CODE}'
      AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'BMO'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BMO'"
