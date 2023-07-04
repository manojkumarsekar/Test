#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-6192 : Initial Version

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_security_uploader @remove_lock @esidev_6192
Feature: 009 | Security Uploader | Record Lock | Remove Lock

  Verify Lock is removed when REMOVE_LOCK attribute is set to Y to existing ISCL. Also verify data is updated as lock is removed from the record

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "SBD5CMH28_BRS_F10.xml" to variable "INPUT_FILENAME_BRS_F10"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_SBD5CMH28A_ApplyLock_Y.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER_APPLYLOCK"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_SBD5CMH28A_RemoveLock_Y.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER_REMOVELOCK"
    And I inactivate "SBD5CMH28" instruments in GC database
    And I inactivate "SBD5CMH28" instruments in VD database

  Scenario: Loading Securities using Security Uploader BCUSIP SBD5CMH28 and RDMSCTYP ADR and Apply Lock Y

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER_APPLYLOCK} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER_APPLYLOCK} |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE               |

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

    Given I execute below query and extract values of "ISS_CLSF_OID" into same variables
    """
    select ISS_CLSF_OID as ISS_CLSF_OID from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
     """

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

  Scenario: Loading Securities using Security Uploader BCUSIP SBD5CMH28 and RDMSCTYP ADR and Remove Lock Y

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER_REMOVELOCK} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER_REMOVELOCK} |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE                |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for OVRC
  Expect FT_T_OVRC should be end_dated with ISS_CLSF_OID

    Then I expect value of column "ovrc_count" in the below SQL query equals to "1":
    """
    select count(*) as ovrc_count from ft_t_ovrc
    where OVR_REF_OID in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and trunc(end_tms) = trunc(sysdate)
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
  Expect FT_T_ISCL should change to COM

    Then I expect value of column "iscl_adr_nochange" in the below SQL query equals to "COM":
    """
    select cl_value as iscl_adr_nochange from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """