#https://collaborate.pruconnect.net/display/EISTOMR4/Taiwan+Portfolio-Security-Broker+Mapping
#https://collaborate.pruconnect.net/display/EISTOMR3/Taiwan+Portfolio-Security-Broker+Mapping+Templates
#https://jira.pruconnect.net/browse/EISDEV-5517

@gc_interface_broker
@dmp_regression_unittest
@dmp_taiwan
@esidev_5517 @dmp_pf_sec_broker_mapping_verify_datamapping
Feature: 001 | Portfolio Security Broker Mapping | Verify Data Mapping

  We are mapping below fields in DMP. This feature files is to verify that the data received in incoming file is mapped in DMP as expected
  Data Sample
  1. Loading Data with CRTSID = TT162, BCUSIP = BRSG1PBZ9 and EIS_TW_BRS_BROKER_CODE = T_FIL-TW
  2. Loading Data with ALTCRTSID = TT162, ISIN = LU0346391831 and EIS_TW_BRS_BROKER_CODE = T_FIL-TW
  3. Loading Data with ESPORTCODE = TT162, EISSECID = ESI7393330 and EIS_TW_BRS_BROKER_CODE = T_FIL-TW
  4. Loading Data with EISPRTID = ESP5279904, ISIN = LU0346391831 and EIS_TW_BRS_BROKER_CODE = T_FIL-TW

  Scenario: End date existing FT_T_CCRF entries in GC

    Given I execute below query to "Update END_TMS to SYSDATE for CCRF"
	"""
    UPDATE FT_T_CCRF C SET END_TMS = SYSDATE WHERE C.CNTL_CROSS_REF_OID IN (
    SELECT  DISTINCT CCRF.CNTL_CROSS_REF_OID  FROM FT_T_CCRF CCRF, FT_T_ACID ACID, FT_T_ISID ISID
    WHERE CCRF.INSTR_ID = ISID.INSTR_ID
    AND CCRF.ACCT_ID = ACID.ACCT_ID
    AND CCRF.ACCT_BK_ID = ACID.BK_ID
    AND CCRF.ACCT_ORG_ID = ACID.ORG_ID
    AND ISID.END_TMS IS NULL
    AND ACID.END_TMS IS NULL
    AND CCRF.END_TMS IS NULL
    AND ISID.ISS_ID IN ('LU0346388373','BRSG1PBZ9','LU0346391831','ESI7393330')
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TT162');
    COMMIT
    """

  Scenario: Update END_TMS to NULL For FIID

    Given I execute below query to "Update END_TMS to SYSDATE for CCRF"
	"""
    UPDATE FT_T_FIID SET FINS_ID = 'T_FIL-TW' WHERE FIID_OID IN ('FY$ky.)LG1','FY$ly.)LG1');
    COMMIT
    """

  Scenario: Loading Data using Portfolio Security Broker Mapping Uploader

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Portfolio_Security_Broker_Mapping" to variable "TESTDATA_PATH"
    And I assign "DMP_PortfolioSecurityBrokerMappingTemplate_DataMapping.xlsx" to variable "INPUT_FILENAME"

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_DMP_TW_PF_SEC_BROKER_MAPPING |

    Then I expect workflow is processed in DMP with success record count as "4"

  Scenario: Data verification in GC
  Expect CCRF is created for all 4 records with LAST_CHG_USR_ID = 'EIS_DMP_TW_PF_SEC_BROKER_MAPPING'

    Then I expect value of column "CCRF_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS CCRF_COUNT FROM FT_T_CCRF CCRF, FT_T_ACID ACID, FT_T_ISID ISID, FT_T_FINR FINR, FT_T_FIID FIID
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
    AND ISID.ISS_ID IN ('LU0346388373','BRSG1PBZ9','LU0346391831','ESI7393330')
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TT162'
    AND FIID.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
    AND FIID.FINS_ID = 'T_FIL-TW'
    AND CCRF.LAST_CHG_USR_ID = 'EIS_DMP_TW_PF_SEC_BROKER_MAPPING'
    AND TRUNC(CCRF.START_TMS) = TRUNC(SYSDATE)
    """