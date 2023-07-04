@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_01 @tom_4434
Feature: SCN01:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_01" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "SCN_SECLINK__RDM_01.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    Given I assign "SCN_SECLINK__BRS_01.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"

    Given I assign "SCN_SECLINK__BNP_01.out" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | INSTR_ID | BNP_INSTRID |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BCUSIP}','${BNP_INSTRID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BCUSIP}','${BNP_INSTRID}'"

  Scenario: TC_2:New Security Creation with RDM feed
  New Security should be created when certain conditions are does not match in the DMP as per RDM Methodology.

    Given I assign "SCN_SECLINK__RDM_01.csv" to variable "INPUT_FILENAME"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_ISID_RDM_COUNT" in the below SQL query equals to "6":
        """
        SELECT COUNT(*) AS RDM_ISID_RDM_COUNT FROM FT_T_ISID
        WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND DATA_SRC_ID = 'EIS'
        AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
        """

    Then I expect value of column "RDM_MKID_COUNT" in the below SQL query equals to "4":
        """
        SELECT COUNT(*) AS RDM_MKID_COUNT FROM FT_T_MKID A
        JOIN FT_T_MKIS B
        ON A.MKT_OID = B.MKT_OID
        JOIN FT_T_ISID C
        ON B.INSTR_ID = C.INSTR_ID
        AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
        WHERE C.ISS_ID='${ISS_ID}'
        AND A.MKT_ID_CTXT_TYP = 'INHOUSE'
        AND C.END_TMS IS NULL
        AND A.DATA_STAT_TYP='ACTIVE'
        AND B.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
        """

    Then I expect value of column "RDM_MKIS_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS RDM_MKIS_COUNT
        FROM FT_T_MKIS
        WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
        AND TRDNG_STAT_TYP='ACTIVE'
        """

  Scenario: TC_3:Existing Security Update with BRS Feed
  Existing security should be updated with BRS feed when certain conditions are matched as per BRS Methodology

    Given I assign "SCN_SECLINK__BRS_01.xml" to variable "INPUT_FILENAME"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_ISID_RDM_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BRS_ISID_RDM_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'EIS'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "BRS_ISID_BRS_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BRS_ISID_BRS_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'BRS'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
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

    Then I expect value of column "BRS_MKID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKID_COUNT FROM FT_T_MKID A
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

  Scenario: TC_4:Existing Security Update with BNP Feed
  Existing security should be updated with BNP feed when certain conditions are matched as per BNP Methodology

    Given I assign "SCN_SECLINK__BNP_01.out" to variable "INPUT_FILENAME"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_ISID_RDM_DATA_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS BNP_ISID_RDM_DATA_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'EIS'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "BNP_ISID_BRS_DATA_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BNP_ISID_BRS_DATA_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'BRS'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      """

    Then I expect value of column "BNP_ISID_BNP_DATA_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BNP_ISID_BNP_DATA_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'BNP'
      AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
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
      AND A.MKT_ID_CTXT_TYP = 'ALADDIN'
      AND C.END_TMS IS NULL
      AND A.DATA_STAT_TYP='ACTIVE'
      AND B.LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
      """

  Scenario: TC_5:Verify Data in FT_T_ISID

    Given I export below sql query results to CSV file "${testdata.path}/data-compare/Actual_FT_T_ISID_Data.csv"
    """
    SELECT ID_CTXT_TYP,ISS_ID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,GLOBAL_UNIQ_IND,LAST_CHG_USR_ID FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND DATA_SRC_ID IN ('EIS','BNP','BRS')
    AND LAST_CHG_USR_ID IN ('EIS_RDM_DMP_EOD_SECURITY','EIS_BNP_DMP_SECURITY','EIS_BRS_DMP_SECURITY')
    AND ID_CTXT_TYP NOT IN ('EISLSTID','EISSECID')
    ORDER BY LAST_CHG_TMS
    """

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/data-compare/Actual_FT_T_ISID_Data.csv" and reference CSV file "${testdata.path}/data-compare/Expected_FT_T_ISID_Data.csv" should be successful and exceptions to be written to "${testdata.path}/data-compare/FT_T_ISID_exceptions_${recon.timestamp}.csv" file

  Scenario: TC_6:Verify Data in FT_T_MKID

    Given I export below sql query results to CSV file "${testdata.path}/data-compare/Actual_FT_T_MKID_Data.csv"
    """
    SELECT A.MKT_ID_CTXT_TYP,A.MKT_ID,A.LAST_CHG_USR_ID,A.DATA_STAT_TYP,B.LAST_CHG_USR_ID,B.TRDNG_STAT_TYP,B.TRDNG_CURR_CDE,B.TRD_LOT_SIZE_CQTY,B.DATA_SRC_ID,B.RND_LOT_SZ_CQTY,C.ID_CTXT_TYP,C.ISS_ID FROM FT_T_MKID A
    JOIN FT_T_MKIS B
    ON A.MKT_OID = B.MKT_OID
    AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
    JOIN FT_T_ISID C
    ON B.INSTR_ID = C.INSTR_ID
    WHERE C.ISS_ID='${ISS_ID}'
    AND C.END_TMS IS NULL
    AND A.DATA_STAT_TYP='ACTIVE'
    """

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/data-compare/Actual_FT_T_MKID_Data.csv" and reference CSV file "${testdata.path}/data-compare/Expected_FT_T_MKID_Data.csv" should be successful and exceptions to be written to "${testdata.path}/data-compare/FT_T_MKID_exceptions_${recon.timestamp}.csv" file

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BCUSIP}','${BNP_INSTRID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${BCUSIP}','${BNP_INSTRID}'"

