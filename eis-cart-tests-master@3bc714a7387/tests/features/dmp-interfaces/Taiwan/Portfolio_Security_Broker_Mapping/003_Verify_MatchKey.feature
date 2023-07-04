#https://collaborate.pruconnect.net/display/EISTOMR4/Taiwan+Portfolio-Security-Broker+Mapping
#https://collaborate.pruconnect.net/display/EISTOMR3/Taiwan+Portfolio-Security-Broker+Mapping+Templates
#https://jira.pruconnect.net/browse/EISDEV-5517

@gc_interface_broker
@dmp_regression_unittest
@dmp_taiwan
@dmp_pf_sec_broker_mapping @esidev_5517 @dmp_pf_sec_broker_mapping_verify_matchkey
Feature: 003 | Portfolio Security Broker Mapping | Verify Match Key

  UC 1 : Verify if the data is already set up from UI for a unique Security-Portfolio-Broker, When an update is sent there is no change in the dataset.
  Loading Data with CRTSID = TT162, ISIN =  LU0370789132 and EIS_TW_BRS_BROKER_CODE = T_FIL-TW
  UC 2 : Verify if the data is already set up from Loader for a unique Security-Portfolio-Broker, When an update is sent there is no change in the dataset
  Loading Data with CRTSID = TT162, ISIN =  LU0346391831 and EIS_TW_BRS_BROKER_CODE = T_FIL-TW
  UC 3 : Verify if broker data is updated for a unique Security-Portfolio
  Loading Data with CRTSID = TT162, EISSECID =  ESI7393330 and EIS_TW_BRS_BROKER_CODE = T_SCHHK-TW

  Scenario: Loading Data using Portfolio Security Broker Mapping Uploader

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Portfolio_Security_Broker_Mapping" to variable "TESTDATA_PATH"
    And I assign "DMP_PortfolioSecurityBrokerMappingTemplate_MatchKey.xlsx" to variable "INPUT_FILENAME"

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_DMP_TW_PF_SEC_BROKER_MAPPING |

    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: Data Verification for UC1
  Verify if the data is already set up from UI for a unique Security-Portfolio-Broker, When an update is sent there is no change in the dataset

    Then I expect value of column "CCRF_COUNT_UI" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS CCRF_COUNT_UI FROM FT_T_CCRF CCRF, FT_T_ACID ACID, FT_T_ISID ISID, FT_T_FINR FINR, FT_T_FIID FIID
    WHERE CCRF.INSTR_ID = ISID.INSTR_ID
    AND CCRF.ACCT_ID = ACID.ACCT_ID
    AND CCRF.ACCT_BK_ID = ACID.BK_ID
    AND CCRF.ACCT_ORG_ID = ACID.ORG_ID
    AND CCRF.FINR_INST_MNEM = FINR.INST_MNEM
    AND FINR.INST_MNEM = FIID.INST_MNEM
    AND ISID.END_TMS IS NULL
    AND ACID.END_TMS IS NULL
    AND FINR.END_TMS IS NULL
    AND FIID.END_TMS IS NULL
    AND CCRF.END_TMS IS NULL
    AND FINR.FINSRL_TYP = 'BROKER'
    AND ISID.ISS_ID = 'LU0370789132'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TT162'
    AND FIID.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
    AND FIID.FINS_ID = 'T_FIL-TW'
    AND CCRF.LAST_CHG_USR_ID != 'EIS_DMP_TW_PF_SEC_BROKER_MAPPING'
    AND TRUNC(CCRF.START_TMS) != TRUNC(SYSDATE)
    """

  Scenario: Data Verification for UC2
  Verify if the data is already set up from Loader for a unique Security-Portfolio-Broker, When an update is sent there is no change in the dataset

    Then I expect value of column "CCRF_COUNT_LOADER" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS CCRF_COUNT_LOADER FROM FT_T_CCRF CCRF, FT_T_ACID ACID, FT_T_ISID ISID, FT_T_FINR FINR, FT_T_FIID FIID
    WHERE CCRF.INSTR_ID = ISID.INSTR_ID
    AND CCRF.ACCT_ID = ACID.ACCT_ID
    AND CCRF.ACCT_BK_ID = ACID.BK_ID
    AND CCRF.ACCT_ORG_ID = ACID.ORG_ID
    AND CCRF.FINR_INST_MNEM = FINR.INST_MNEM
    AND FINR.INST_MNEM = FIID.INST_MNEM
    AND ISID.END_TMS IS NULL
    AND ACID.END_TMS IS NULL
    AND FINR.END_TMS IS NULL
    AND FIID.END_TMS IS NULL
    AND CCRF.END_TMS IS NULL
    AND FINR.FINSRL_TYP = 'BROKER'
    AND ISID.ISS_ID = 'LU0346391831'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TT162'
    AND FIID.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
    AND FIID.FINS_ID = 'T_FIL-TW'
    AND CCRF.LAST_CHG_USR_ID = 'EIS_DMP_TW_PF_SEC_BROKER_MAPPING'
    AND TRUNC(CCRF.START_TMS) = TRUNC(SYSDATE)
    """

  Scenario: Data Verification for UC3
  Verify if broker data is updated for a unique Security-Portfolio

    Then I expect value of column "CCRF_COUNT_UPDATED" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS CCRF_COUNT_UPDATED FROM FT_T_CCRF CCRF, FT_T_ACID ACID, FT_T_ISID ISID, FT_T_FINR FINR, FT_T_FIID FIID
    WHERE CCRF.INSTR_ID = ISID.INSTR_ID
    AND CCRF.ACCT_ID = ACID.ACCT_ID
    AND CCRF.ACCT_BK_ID = ACID.BK_ID
    AND CCRF.ACCT_ORG_ID = ACID.ORG_ID
    AND CCRF.FINR_INST_MNEM = FINR.INST_MNEM
    AND FINR.INST_MNEM = FIID.INST_MNEM
    AND ISID.END_TMS IS NULL
    AND ACID.END_TMS IS NULL
    AND FINR.END_TMS IS NULL
    AND FIID.END_TMS IS NULL
    AND CCRF.END_TMS IS NULL
    AND FINR.FINSRL_TYP = 'BROKER'
    AND ISID.ISS_ID = 'ESI7393330'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TT162'
    AND FIID.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
    AND FIID.FINS_ID = 'T_SCHHK-TW'
    AND CCRF.LAST_CHG_USR_ID = 'EIS_DMP_TW_PF_SEC_BROKER_MAPPING'
    AND TRUNC(CCRF.START_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "CCRF_COUNT_OLD" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS CCRF_COUNT_OLD FROM FT_T_CCRF CCRF, FT_T_ACID ACID, FT_T_ISID ISID, FT_T_FINR FINR, FT_T_FIID FIID
    WHERE CCRF.INSTR_ID = ISID.INSTR_ID
    AND CCRF.ACCT_ID = ACID.ACCT_ID
    AND CCRF.ACCT_BK_ID = ACID.BK_ID
    AND CCRF.ACCT_ORG_ID = ACID.ORG_ID
    AND CCRF.FINR_INST_MNEM = FINR.INST_MNEM
    AND FINR.INST_MNEM = FIID.INST_MNEM
    AND ISID.END_TMS IS NULL
    AND ACID.END_TMS IS NULL
    AND FINR.END_TMS IS NULL
    AND FIID.END_TMS IS NULL
    AND CCRF.END_TMS IS NULL
    AND FINR.FINSRL_TYP = 'BROKER'
    AND ISID.ISS_ID = 'ESI7393330'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TT162'
    AND FIID.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
    AND FIID.FINS_ID = 'T_FIL-TW'
    """