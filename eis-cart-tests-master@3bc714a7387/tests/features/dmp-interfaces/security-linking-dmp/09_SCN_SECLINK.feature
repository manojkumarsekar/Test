@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_09 @tom_4434
Feature: SCN09: Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_09" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "SCN_SECLINK__BNP_09.out" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BRS_09.xml" to variable "INPUT_FILENAME2"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME1}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | ISIN        | BNP_ISIN   |
      | SEDOL       | ISS_ID     |
      | HIP_EXT2_ID | BNP_BCUSIP |

    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='I']/../IDENTIFIER" to variable "BRS_ISIN"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='A']/../IDENTIFIER" to variable "BRS_CUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "CUSIP" to variable "BRS_BCUSIP"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BNP_ISIN}','${ISS_ID}','${BNP_BCUSIP}','${BRS_ISIN}','${BRS_CUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BNP_ISIN}','${ISS_ID}','${BNP_BCUSIP}','${BRS_ISIN}','${BRS_CUSIP}'"

  Scenario: TC_2:Validate all listing level IDs once match is found. When identifier is found matched however there is another listing attached on the next ID in hierarchy
  Since BRS is high ranker vendor than BNP, ISIN will be updated, market will be updated successfully and there will be two BCUSIP both with the new market.

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      """

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
      SELECT * FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_MKID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
      AND A.MKT_ID_CTXT_TYP = 'MIC'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "10":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "9":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BRS_ISID_ISIN_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_ISID_ISIN_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      AND ID_CTXT_TYP = 'ISIN'
      AND ISS_ID = '${BRS_ISIN}'
      """

    Then I expect value of column "BRS_ISID_BCUSIP_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_ISID_BCUSIP_COUNT FROM FT_T_ISID
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      AND ID_CTXT_TYP = 'BCUSIP'
      AND ISS_ID IN ('${BNP_BCUSIP}','${BRS_BCUSIP}')
      """

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      """

    #After Loading BRS feed MKT_OID should be updated, hence no rows with old MKT_OID
    Then I expect value of column "BRS_MKIS_MKT_OID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS BRS_MKIS_MKT_OID_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      AND MKT_OID = '${MKT_OID}'
      """

    Then I expect value of column "BRS_UPDATE_MKID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      WHERE C.ISS_ID='${ISS_ID}'
      AND A.MKT_ID_CTXT_TYP = 'ALADDIN'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

    And I expect value of column "BRS_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BRS_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """