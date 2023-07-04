#https://jira.pruconnect.net/browse/EISDEV-5534
#https://jira.pruconnect.net/browse/EISDEV-6173 : Adding PM email id setup in db as part of prerequisite.

@gc_interface_portfolios
@dmp_regression_unittest
@dmp_taiwan
@eisdev_5534 @eisdev_6173 @eisdev_7571
Feature: This feature is to test the mapping of SUBP_EIS_SEC_ID,SUBP_ISIN,AUT_EIS_SEC_ID,AUT_ISIN

  Load portfolio template file having below scenario
  1. with SUBP_EIS_SEC_ID and	AUT_EIS_SEC_ID
  2. with SUBP_ISIN and AUT_ISIN
  3. with Invalid EISSECID for SUBP and AUT
  4. with Invalid ISIN for SUBP and AUT

  Scenario: End date AISR data for the test accounts and setup variables
  deleting existing AISR entries to load data using the current file load

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "DMP_R3_PortfolioMasteringTemplate_Final_4.9_EISDEV_5534.xlsx" to variable "PORTFOLIO_TEMPLATE"

    And I execute below query to "Update existing EXTR.TRD_ID to new oid"
	"""
    delete ft_t_aisr where
    acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('TSTA5268','TSTD5268','TSTLA5268','TSTB5268'));
    COMMIT
    """

    #Clear FPRO Data
    And I execute below query to "End Date the FPRO data if exists"
      """
        UPDATE FT_T_FPRO SET END_TMS=SYSDATE-1
        WHERE FINS_PRO_ID='joanna.ong@eastspring.com' AND PRO_DESIGNATION_TXT='PM';
        COMMIT;
      """

    And I execute below query and extract values of "FPRO_OID;FINS_PRO_ID" into same variables
      """
       SELECT FPRO_OID,FINS_PRO_ID FROM FT_T_FPRO where ROWNUM=1 AND END_TMS IS NULL
      """

    And I execute below query to "Update PM mail id"
      """
        UPDATE FT_T_FPRO SET FINS_PRO_ID='joanna.ong@eastspring.com',PRO_DESIGNATION_TXT='PM'
        WHERE FPRO_OID='${FPRO_OID}';
        COMMIT
      """

  Scenario: Load portfolio Template
  Verify Portfolio Template is Successfully Loaded with Success Count 2

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Verify Data with EISSECID for SUBP and AUT
  Verify 1 Record for AISR with ACCT_ISSU_RL_TYP = 'SUBP' is created for fund TSTA5268 and security ESI5067219
  Verify 1 Record for AISR with ACCT_ISSU_RL_TYP = 'AUT' is created for fund TSTA5268 and security ESI4336528

    Then I expect value of column "AISR_SUBP_SECID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_SUBP_SECID FROM FT_T_AISR AISR, FT_T_ACID ACID, FT_T_ISID ISID
    WHERE AISR.INSTR_ID = ISID.INSTR_ID
    AND ACID.ACCT_ID = AISR.ACCT_ID
    AND AISR.ACCT_ISSU_RL_TYP = 'SUBP'
    AND ACID.ACCT_ALT_ID = 'TSTA5268'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.END_TMS IS NULL
    AND ISID.ISS_ID = 'ESI5067219'
    AND ISID.ID_CTXT_TYP = 'EISSECID'
    AND ISID.END_TMS IS NULL
    AND AISR.LAST_CHG_USR_ID = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND TRUNC(AISR.LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "AISR_AUT_SECID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_AUT_SECID FROM FT_T_AISR AISR, FT_T_ACID ACID, FT_T_ISID ISID
    WHERE AISR.INSTR_ID = ISID.INSTR_ID
    AND ACID.ACCT_ID = AISR.ACCT_ID
    AND AISR.ACCT_ISSU_RL_TYP = 'AUT'
    AND ACID.ACCT_ALT_ID = 'TSTA5268'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.END_TMS IS NULL
    AND ISID.ISS_ID = 'ESI4336528'
    AND ISID.ID_CTXT_TYP = 'EISSECID'
    AND ISID.END_TMS IS NULL
    AND AISR.LAST_CHG_USR_ID = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND TRUNC(AISR.LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

  Scenario: Verify Data with ISIN for SUBP and AUT
  Verify 1 Record for AISR with ACCT_ISSU_RL_TYP = 'SUBP' is created for fund TSTD5268 and security US3138WFXD36
  Verify 1 Record for AISR with ACCT_ISSU_RL_TYP = 'AUT' is created for fund TSTD5268 and security US65478WAC91

    Then I expect value of column "AISR_SUBP_ISIN" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_SUBP_ISIN FROM FT_T_AISR AISR, FT_T_ACID ACID, FT_T_ISID ISID
    WHERE AISR.INSTR_ID = ISID.INSTR_ID
    AND ACID.ACCT_ID = AISR.ACCT_ID
    AND AISR.ACCT_ISSU_RL_TYP = 'SUBP'
    AND ACID.ACCT_ALT_ID = 'TSTD5268'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.END_TMS IS NULL
    AND ISID.ISS_ID = 'US3138WFXD36'
    AND ISID.ID_CTXT_TYP = 'ISIN'
    AND ISID.END_TMS IS NULL
    AND AISR.LAST_CHG_USR_ID = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND TRUNC(AISR.LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

    Then I expect value of column "AISR_AUT_ISIN" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_AUT_ISIN FROM FT_T_AISR AISR, FT_T_ACID ACID, FT_T_ISID ISID
    WHERE AISR.INSTR_ID = ISID.INSTR_ID
    AND ACID.ACCT_ID = AISR.ACCT_ID
    AND AISR.ACCT_ISSU_RL_TYP = 'AUT'
    AND ACID.ACCT_ALT_ID = 'TSTD5268'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.END_TMS IS NULL
    AND ISID.ISS_ID = 'US65478WAC91'
    AND ISID.ID_CTXT_TYP = 'ISIN'
    AND ISID.END_TMS IS NULL
    AND AISR.LAST_CHG_USR_ID = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND TRUNC(AISR.LAST_CHG_TMS) = TRUNC(SYSDATE)
    """

  Scenario: Verify Exception is thrown with Invalid EISSECID for SUBP and AUT

    Then I expect value of column "AISR_SUBP_SECID_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_SUBP_SECID_EXCEPTION FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '3')
    AND PARM_VAL_TXT = 'EISSECID INVALIDSUBSEC EIS IssueIdentifier'
    """

    Then I expect value of column "AISR_AUT_SECID_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_AUT_SECID_EXCEPTION FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '3')
    AND PARM_VAL_TXT = 'EISSECID INVALIDAUTSEC EIS IssueIdentifier'
    """

  Scenario: Verify Exception is thrown with Invalid ISIN for SUBP and AUT

    Then I expect value of column "AISR_SUBP_ISIN_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_SUBP_ISIN_EXCEPTION FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '4')
    AND PARM_VAL_TXT = 'ISIN INVALIDSUBISIN EIS IssueIdentifier'
    """

    Then I expect value of column "AISR_AUT_ISIN_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS AISR_AUT_ISIN_EXCEPTION FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '4')
    AND PARM_VAL_TXT = 'ISIN INVALIDAUTISIN EIS IssueIdentifier'
    """

  Scenario: Reverting the PM mail changes

    Then I execute below query to "Reverting the PM mail id changes"
    """
     UPDATE FT_T_FPRO SET FINS_PRO_ID='${FINS_PRO_ID}',PRO_DESIGNATION_TXT = NULL
     WHERE FPRO_OID='${FPRO_OID}';
     COMMIT
    """