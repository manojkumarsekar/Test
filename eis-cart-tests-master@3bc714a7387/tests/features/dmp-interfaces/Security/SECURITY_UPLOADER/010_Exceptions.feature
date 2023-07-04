#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-6192 : Initial Version

@gc_interface_securities
@dmp_regression_unittest
@dmp_security_uploader @security_uploader_exceptions @esidev_6192
Feature: 010 | Security Uploader | Exceptions

  Verify Exceptions are thrown for missing mandatory fields or invalid MIC/GS_ISSUE_TYPE /RDMSECTYPE is provided in the input record

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "SBD5CMH28_BRS_F10.xml" to variable "INPUT_FILENAME_BRS_F10"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_Exceptions.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER"
    And I inactivate "SBD5CMH28" instruments in GC database
    And I inactivate "SBD5CMH28" instruments in VD database

  Scenario: Loading Securities using Security Uploader BCUSIP SBD5CMH28 and RDMSCTYP ADR and Apply Lock Y

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE     |

    Then I expect workflow is processed in DMP with success record count as "0"

  Scenario: Data verification for NTEL for Missing Security Description
  Expect FT_T_NTEL should throw error for missing security description

    Then I expect value of column "ntel_count_rec1" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count_rec1 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 1)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 60001 and MSG_SEVERITY_CDE = 40 and
    PARM_VAL_TXT like 'User defined Error thrown! . Cannot process file as required fields, SECURITY DESCRIPTION is not present in input record'
    """

  Scenario: Data verification for NTEL for Missing GS_ISSUE_TYPE
  Expect FT_T_NTEL should throw error for missing GS_ISSUE_TYPE

    Then I expect value of column "ntel_count_rec2" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count_rec2 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 2)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 60001 and MSG_SEVERITY_CDE = 40 and
    PARM_VAL_TXT like 'User defined Error thrown! . Cannot process file as required fields, GS_ISSUE_TYPE is not present in input record'
    """

  Scenario: Data verification for NTEL for Missing MIC
  Expect FT_T_NTEL should throw error for missing MIC

    Then I expect value of column "ntel_count_rec3" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count_rec3 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 3)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 60001 and MSG_SEVERITY_CDE = 40 and
    PARM_VAL_TXT like 'User defined Error thrown! . Cannot process file as required fields, MIC is not present in input record'
    """

  Scenario: Data verification for NTEL for Missing SEC_CURRENCY
  Expect FT_T_NTEL should throw error for missing SEC_CURRENCY

    Then I expect value of column "ntel_count_rec4" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count_rec4 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 4)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 60001 and MSG_SEVERITY_CDE = 40 and
    PARM_VAL_TXT like 'User defined Error thrown! . Cannot process file as required fields, SEC_CURRENCY is not present in input record'
    """

  Scenario: Data verification for NTEL for Missing Identifier
  Expect FT_T_NTEL should throw error for missing Identifie

    Then I expect value of column "ntel_count_rec5" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count_rec5 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 5)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 60001 and MSG_SEVERITY_CDE = 40 and
    PARM_VAL_TXT like 'User defined Error thrown! . Cannot process file as required fields, SECURITY DESCRIPTION, Security Identifier is not present in input record'
    """

  Scenario: Data verification for NTEL for Invalid MIC
  Expect FT_T_NTEL should throw error for Invalid MIC in GC and VD both schema both

    Then I expect value of column "ntel_count_rec6" in the below SQL query equals to "2":
    """
    select count(*) as ntel_count_rec6 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 6)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 3 and MSG_SEVERITY_CDE = 40
    and char_val_txt like 'The exchange %MIC - INVALIDMIC% received from EIS  is not present in the FinancialMarketIdentifier.'
    """

  Scenario: Data verification for NTEL for Invalid Currency
  Expect FT_T_NTEL should throw error for Invalid Currency

    Then I expect value of column "ntel_count_rec7" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count_rec7 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 7)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 207 and MSG_SEVERITY_CDE = 40
    and PARM_VAL_TXT like 'Issue EIS  Denominated Currency = INVALIDCURR'
    """

  Scenario: Data verification for NTEL for Invalid RDM Sec Type
  Expect FT_T_NTEL should throw error for Invalid RDM Sec Type in GC and VD both schema both

    Then I expect value of column "ntel_count_rec8" in the below SQL query equals to "2":
    """
    select count(*) as ntel_count_rec8 from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 8)
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 4 and MSG_SEVERITY_CDE = 40
    and PARM_VAL_TXT like 'INVALIDRDMSECTYP  IndustryClassification'
    """