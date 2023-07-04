#EISDEV-6261 : This feature file tests security update between RDM and BRS and BNP.
#Since RDM is a decommissioned interface.
#Adding ignore tag for scenario #1 and 3 to exclude running from regression tests
#Updating Scenario 2 from RDM to RCR LBU

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_04 @eisdev_6261
Feature: SCN04:Security Linking Criteria: Data Management Platform (Golden Source)

  Security update on existing security in DMP through any feed file load from BRS/BOCI/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_04" to variable "testdata.path"
    And I assign "SCN_SECLINK__BRS_VALID_MKT_04.xml" to variable "INPUT_FILENAME"

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "CUSIP_ID"

    And I assign "SCN_SECLINK__RDM_VALID_MKT_04.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISIN | ISS_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${CUSIP_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${CUSIP_ID}'"

  @ignore
  Scenario: TC_1: Market update on Existing Security in DMP through RDM feed load
  Old Listing was updated new market provided by RDM. All the identifiers were also moved to new market.

    Given I assign "SCN_SECLINK__RDM_INVALID_MKT_04.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__RDM_VALID_MKT_04.csv" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" with reference to "CLIENT_ID" column and assign to variables:
      | ISO_MIC | MKT_ID |

    Then I expect value of column "RDM_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS RDM_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      """

    Then I expect value of column "RDM_UPDATE_MKT_MKID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS RDM_UPDATE_MKT_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      WHERE C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL AND A.DATA_STAT_TYP='ACTIVE' AND A.MKT_ID='${MKT_ID}'
      """

  Scenario: TC_2: Market update on Existing Security in DMP through BNP feed load with valid Exchange
  Old Listing was updated new market provided by BNP. All the identifiers were also moved to new market.

    Given I assign "BOCIEISLINSTMT.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_VALID_MKT_04.out" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | PRIMARY_EXCHANGE | MKT_ID |

    Then I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_UPDATE_MKT_MKID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      WHERE C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL AND A.DATA_STAT_TYP='ACTIVE' AND A.MKT_ID='${MKT_ID}'
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

  @ignore
  Scenario: TC_3: Market update on Existing Security in DMP through BNP feed load with ISO_MIC as XXXX
  Old Listing was updated new market provided by BNP. All the identifiers were also moved to new market.

    Given I assign "SCN_SECLINK__RDM_INVALID_MKT_04.csv" to variable "INPUT_FILENAME"
    And I assign "SCN_SECLINK__BNP_VALID_XXXX_MKT_04.out" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | PRIMARY_EXCHANGE | MKT_ID |

    Then I expect value of column "BNP_UPDATE_MKT_ISID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_ISID_COUNT FROM FT_T_ISID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID=B.MKT_OID
      JOIN FT_T_ISID C
      ON A.INSTR_ID=C.INSTR_ID  AND B.INSTR_ID=C.INSTR_ID  AND C.ISS_ID = '${ISS_ID}'  AND C.END_TMS IS NULL
      WHERE TRUNC(A.LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND A.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

    Then I expect value of column "BNP_UPDATE_MKT_MKID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS BNP_UPDATE_MKT_MKID_COUNT FROM FT_T_MKID A
      JOIN FT_T_MKIS B
      ON A.MKT_OID = B.MKT_OID
      AND TRUNC(B.LAST_CHG_TMS) = TRUNC(SYSDATE)
      JOIN FT_T_ISID C
      ON B.INSTR_ID = C.INSTR_ID
      WHERE C.ISS_ID = '${ISS_ID}' AND C.END_TMS IS NULL AND A.DATA_STAT_TYP='ACTIVE' AND A.MKT_ID='${MKT_ID}'
      AND B.LAST_CHG_USR_ID='EIS_BNP_DMP_SECURITY'
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${CUSIP_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP_ID}'"
