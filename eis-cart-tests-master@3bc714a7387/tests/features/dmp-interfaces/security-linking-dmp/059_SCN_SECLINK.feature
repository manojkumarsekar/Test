@gc_interface_securities @gc_interface_orders
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_059
Feature: SCN59 : Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_059" to variable "testdata.path"
    And I assign "SCN_SECLINK__BRS_059.xml" to variable "INPUT_FILENAME1"
    And I assign "esi_order_SECLINK_BRS.xml" to variable "INPUT_FILENAME2"

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with tagName "CUSIP" to variable "ISS_ID"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

  Scenario: TC_1: Load BRS feed for orders with dummy market. If there is a valid market in DMP, verify that dummy market is not updated.
  Dummy market will not update the valid market. Warning will not be raised.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND ID_CTXT_TYP = 'BCUSIP'
      """

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
      SELECT * FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | esi_order*.xml    |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS |
      | BUSINESS_FEED |                   |

    Then I expect value of column "BRS_MKIS_MKT_OID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_MKT_OID_COUNT FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND MKT_OID = '${MKT_OID}'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
