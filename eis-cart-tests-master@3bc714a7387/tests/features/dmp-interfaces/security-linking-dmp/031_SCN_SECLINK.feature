@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_031
Feature: SCN31:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_031" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario
    Given I assign "SCN_SECLINK__RDM_031.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_031.xml" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify security linking during BRS feed load for BCUSIP not existing in DMP
  Security should get created successfully. With a single listing only

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'EIS'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'EIS'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'BRS'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='I']/../IDENTIFIER" to variable "ISIN"

    Then I expect value of column "BRS_BCUSIP_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_BCUSIP_CHECK FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'BCUSIP'
      AND ISS_ID = '${BCUSIP}'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
