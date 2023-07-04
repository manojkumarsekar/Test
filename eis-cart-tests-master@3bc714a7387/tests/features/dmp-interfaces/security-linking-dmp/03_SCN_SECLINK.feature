@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_03 @tom_4434
Feature: SCN03:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_03" to variable "testdata.path"

    Given I assign "SCN_SECLINK__RDM_Without_LOT_SIZE_03.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN  | ISS_ID   |
      | SEDOL | SEDOL_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${SEDOL_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_ID}'"

  @dmp_wf_smoke
  Scenario: TC_1:New Security Creation with RDM feed Without Round Lot Size
  New Security should be created when certain conditions are does not match in the DMP as per RDM Methodology even if ROUND LOT is not present in the feed.

    Given I assign "SCN_SECLINK__RDM_Without_LOT_SIZE_03.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__RDM_With_LOT_SIZE_03.csv" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "RDM_NULL_LOT_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_NULL_LOT_MKIS_COUNT FROM FT_T_MKIS MKIS
      JOIN FT_T_MRKT MRKT
      ON MKIS.MKT_OID = MRKT.MKT_OID
      AND MKIS.RND_LOT_SZ_CQTY= MRKT.RND_LOT_SZ_CQTY
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(MKIS.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND MKIS.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      AND MKIS.TRDNG_STAT_TYP='ACTIVE'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ROUND_LOT_SIZE | RND_LOT_SZ_CQTY |

    Then I expect value of column "RDM_ISID_COUNT" in the below SQL query equals to "6":
      """
      SELECT COUNT(*) AS RDM_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND DATA_SRC_ID = 'EIS'
      AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_EOD_SECURITY'
      """

    Then I expect value of column "RDM_UPDATE_LOT_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RDM_UPDATE_LOT_MKIS_COUNT
      FROM FT_T_MKIS
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      AND TRDNG_STAT_TYP='ACTIVE'
      AND RND_LOT_SZ_CQTY = ${RND_LOT_SZ_CQTY}
      """

    Then I expect value of column "RDM_MKID_COUNT" in the below SQL query equals to "2":
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

  @dmp_wf_smoke
  Scenario: TC_2:Security update on the Existing Security in DMP through BRS feed
  Existing security should be updated with valid ROUND LOT size. New listings should not be created.

    Given I assign "SCN_SECLINK__RDM_Without_LOT_SIZE_03.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BRS_03.xml" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "BRS_UPDATE_LOT_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_UPDATE_LOT_MKIS_COUNT FROM FT_T_MKIS MKIS
      JOIN FT_T_MRKT MRKT
      ON MKIS.MKT_OID = MRKT.MKT_OID
      AND MKIS.RND_LOT_SZ_CQTY= MRKT.RND_LOT_SZ_CQTY
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(MKIS.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND MKIS.LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'
      AND MKIS.TRDNG_STAT_TYP='ACTIVE'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME2}" with tagName "MIN_LOT_SIZE" to variable "RND_LOT_SZ_CQTY"

    Then I expect value of column "BRS_ISID_COUNT" in the below SQL query equals to "11":
      """
      SELECT COUNT(*) AS BRS_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BRS_UPDATE_LOT_MKIS_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_UPDATE_LOT_MKIS_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
    AND TRDNG_STAT_TYP='ACTIVE'
    AND RND_LOT_SZ_CQTY = ${RND_LOT_SZ_CQTY}
    """

    Then I expect value of column "BRS_MKID_COUNT" in the below SQL query equals to "3":
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

  @dmp_wf_smoke
  Scenario: TC_3:Security update on the Existing Security in DMP through BNP feed
  Existing security should be updated with valid ROUND LOT size. New listings should not be created.

    Given I assign "SCN_SECLINK__BNP_Without_LOT_SIZE_03.out" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_With_LOT_SIZE_03.out" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect value of column "BNP_UPDATE_LOT_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BNP_UPDATE_LOT_MKIS_COUNT FROM FT_T_MKIS MKIS
      JOIN FT_T_MRKT MRKT
      ON MKIS.MKT_OID = MRKT.MKT_OID
      AND MKIS.RND_LOT_SZ_CQTY= MRKT.RND_LOT_SZ_CQTY
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(MKIS.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND MKIS.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      AND MKIS.TRDNG_STAT_TYP='ACTIVE'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | TRADEABLE_QTY | RND_LOT_SZ_CQTY |

    Then I expect value of column "BNP_ISID_COUNT" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS BNP_ISID_COUNT FROM FT_T_ISID
      WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "BNP_UPDATE_LOT_MKIS_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_UPDATE_LOT_MKIS_COUNT
    FROM FT_T_MKIS
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
    AND TRDNG_STAT_TYP='ACTIVE'
    AND RND_LOT_SZ_CQTY = ${RND_LOT_SZ_CQTY}
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

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${SEDOL_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_ID}'"


