@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_030
Feature: SCN30:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_030" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario
    Given I assign "SCN_SECLINK__BRS_030.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "ISS_ID"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify the security creation scenarios when none filter criteria matches with BRS Feed
      Security should get created successfully. With a single listing only

    Given I assign "SCN_SECLINK__BRS_030.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |

    And I process files with below parameters and wait for the job to be completed
      |  FILE_PATTERN | ${INPUT_FILENAME}       |
      |  MESSAGE_TYPE | EIS_MT_BRS_SECURITY_NEW |
      |  BUSINESS_FEED|                         |

    Then I expect value of column "BRS_ISID_CHECK" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_ISID_CHECK FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_ISID_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_CHECK FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP='BCUSIP'
      AND ISS_ID = '${BCUSIP}'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    And I expect value of column "BRS_ISID_MKT_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS BRS_ISID_MKT_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND B.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"



