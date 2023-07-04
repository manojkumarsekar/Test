#EISDEV-6261 : This feature file tests security update between RDM and BRS. Since RDM is a decommissioned interface. Adding ignore tag for scenario #4 to exclude running from regression tests

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_011 @ignore
Feature: SCN11: Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_011" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "SCN_SECLINK__RDM_SEQ1_011.csv" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_011.xml" to variable "INPUT_FILENAME2"
    And I assign "SCN_SECLINK__RDM_SEQ2_011.csv" to variable "INPUT_FILENAME3"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | SEDOL | RDM1_SEDOL |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME3}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | SEDOL | RDM2_SEDOL |
      | ISIN  | RDM2_ISIN  |

    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='I']/../IDENTIFIER" to variable "BRS_ISIN"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='A']/../IDENTIFIER" to variable "BRS_CUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "BRS_SEDOL"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "BRS_BCUSIP"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RDM1_SEDOL}','${RDM2_SEDOL}','${RDM2_ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${RDM1_SEDOL}','${RDM2_SEDOL}','${RDM2_ISIN}'"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BRS_ISIN}','${BRS_CUSIP}','${BRS_SEDOL}','${BRS_BCUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BRS_ISIN}','${BRS_CUSIP}','${BRS_SEDOL}','${BRS_BCUSIP}'"

  Scenario: TC_2:Validate all listing level IDs once match is found. When identifier is found matched however there is another listing attached on the next ID in hierarchy
  Security will be matched on the basis of listing id(RDMID). The market will not be updated as RDM is lower ranking vendor than BRS.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_ISID_UPDATE_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BRS_ISID_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      AND ID_CTXT_TYP IN ('SEDOL','CUSIP','BCUSIP','TICKER','ISIN')
      """

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
      SELECT * FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME3}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_UPDATE_COUNT" in the below SQL query equals to "9":
      """
      SELECT COUNT(*) AS RDM_ISID_UPDATE_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

     #After Loading RDM feed MKT_OID should be NOT updated, hence 1 ROW WITH OLD MKT_OID
    Then I expect value of column "RDM_MKIS_MKT_OID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_MKIS_MKT_OID_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      AND MKT_OID = '${MKT_OID}'
      """

    Then I expect value of column "RDM_ISID_ISIN_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_ISID_ISIN_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${RDM1_SEDOL}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      AND ID_CTXT_TYP = 'ISIN'
      AND ISS_ID = '${BRS_ISIN}'
      """

  Scenario: Cleaning data after Tests

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RDM1_SEDOL}','${RDM2_SEDOL}','${RDM2_ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${RDM1_SEDOL}','${RDM2_SEDOL}','${RDM2_ISIN}'"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BRS_ISIN}','${BRS_CUSIP}','${BRS_SEDOL}','${BRS_BCUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BRS_ISIN}','${BRS_CUSIP}','${BRS_SEDOL}','${BRS_BCUSIP}'"










