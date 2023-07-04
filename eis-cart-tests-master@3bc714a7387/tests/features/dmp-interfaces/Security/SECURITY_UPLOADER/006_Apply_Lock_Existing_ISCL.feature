#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-6192 : Initial Version

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_security_uploader @apply_lock_existing @esidev_6192
Feature: 006 | Security Uploader | Record Lock | Apply Lock Existing ISCL
  Verify Lock is applied when APPLY_LOCK attribute is set to Y to existing ISCL. Also verify data is not updated to lock defined on the record.

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "SBD5CMH28_BRS_F10.xml" to variable "INPUT_FILENAME_BRS_F10"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_SBD5CMH28A_ApplyLock_Y.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER"
    And I inactivate "SBD5CMH28" instruments in GC database
    And I inactivate "SBD5CMH28" instruments in VD database

  Scenario: Loading F10 for BCUSIP SBD5CMH28 and RDMSCTYP COM

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS_F10} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_F10} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW   |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISCL
  Expect FT_T_ISCL should get populated with cl value COM

    Then I expect value of column "iscl_com" in the below SQL query equals to "COM":
    """
    select cl_value as iscl_com from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

    Given I execute below query and extract values of "ISS_CLSF_OID" into same variables
    """
    select ISS_CLSF_OID as ISS_CLSF_OID from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
     """

  Scenario: Loading Securities using Security Uploader BCUSIP SBD5CMH28 and RDMSCTYP ADR and Apply Lock Y

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE     |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISCL
  Expect FT_T_ISCL should get populated with cl value ADR

    Then I expect value of column "iscl_adr" in the below SQL query equals to "ADR":
    """
    select cl_value as iscl_adr from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

  Scenario: Data verification for OVRC
  Expect FT_T_OVRC should get populated with ISS_CLSF_OID

    Then I expect value of column "ovrc_count" in the below SQL query equals to "1":
    """
    select count(*) as ovrc_count from ft_t_ovrc
    where OVR_REF_OID in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and OVR_REF_TYP = 'ISSU'
    and LOCK_LEVEL_TYP = 'RECORD'
    and tbl_id = 'ISCL'
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and OVR_TBL_KEY_TXT = 'ISS_CLSF_OID=${ISS_CLSF_OID};'
    """

  Scenario: Loading F10 for BCUSIP SBD5CMH28 and RDMSCTYP COM

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS_F10} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_F10} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW   |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISCL
  Expect FT_T_ISCL should remain to ADR and not change to COM received from F10

    Then I expect value of column "iscl_adr_nochange" in the below SQL query equals to "ADR":
    """
    select cl_value as iscl_adr_nochange from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

  Scenario: Data verification for NTEL
  Expect FT_T_NTEL should throw a warning for Locking

    Then I expect value of column "ntel_count" in the below SQL query equals to "1":
    """
    select count(*) as ntel_count from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}')
    and NOTFCN_STAT_TYP = 'OPEN'
    and notfcn_id = 258 and MSG_SEVERITY_CDE = 30 and
    char_val_txt like 'The Record: INDUS_CL_SET_ID = RDMSCTYP, INSTR_ID % is Locked; hence the incoming data value received in the message for IssueClassification and it% child shall not be considered for processing. [Table Instance Details (primary key): ISS_CLSF_OID%'
    """