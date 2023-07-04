#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-6192 : Initial Version

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_security_uploader @vsh_brs_eis @esidev_6192
Feature: 005 | Security Uploader | VSH | BRS with EIS
  Verify data set up from BRS is updated via EIS as VSH is Rank 1 for both data sources

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "SBD5CMH28_BRS_F10.xml" to variable "INPUT_FILENAME_BRS_F10"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_SBD5CMH28.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER"
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

  Scenario: Loading Securities using Security Uploader BCUSIP SBD5CMH28 and RDMSCTYP ADR

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
