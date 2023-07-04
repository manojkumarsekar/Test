#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-6192 : Initial Version

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_security_uploader @update_exiting_security_sedol @esidev_6192
Feature: 003 | Security Uploader | Update Existing Security | Attach Sedol Based on BCUSIP
  Verify Sedol from the Security Uploader is attached to existing security and listing set up via F10 based on the listing matching defined in DSID

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "SBD5CMH28_BRS_F10.xml" to variable "INPUT_FILENAME_BRS_F10"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_SBD5CMH28.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER"
    And I inactivate "SBD5CMH28" instruments in GC database
    And I inactivate "SBD5CMH28" instruments in VD database

  Scenario: Loading F10 for BCUSIP SBD5CMH28

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS_F10} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_F10} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW   |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISID
  Expect all the identifiers are stored into FT_T_ISID table

    Then I expect value of column "isid_count" in the below SQL query equals to "8":
    """
    select count(*) as isid_count from ft_t_isid
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Loading Securities using Security Uploader with SEDOL BD5CMH2

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE     |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISID
  SEDOL BD5CMH2 is attached to the same instrument as that of BCUSIP

    Then I expect value of column "isid_BD5CMH2" in the below SQL query equals to "BD5CMH2":
    """
    select iss_id as isid_BD5CMH2 from ft_t_isid
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'SBD5CMH28' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and id_ctxt_typ = 'SEDOL'
    """

  Scenario: Data verification for MKIS
  SEDOL BD5CMH2 is attached to the same listing as that of BCUSIP

    Then I expect value of column "listing_BD5CMH2" in the below SQL query equals to "1":
    """
    select count(distinct mkis.MKT_ISS_OID) as listing_BD5CMH2 from ft_t_isid isid, ft_t_isid mixr_isid, ft_t_mixr mixr, ft_t_mkis mkis
    where mkis.instr_id = isid.instr_id
    and mkis.end_tms is null
    and isid.end_tms is null
    and mixr.end_tms is null
    and mixr_isid.end_tms is null
    and mkis.MKT_ISS_OID = mixr.MKT_ISS_OID
    and mixr.isid_oid = mixr_isid.ISID_OID
    and isid.iss_id = 'SBD5CMH28'
    and isid.ID_CTXT_TYP = 'BCUSIP'
    and mixr_isid.ID_CTXT_TYP in ('BCUSIP','SEDOL')
    and mixr_isid.iss_id in ('BD5CMH2','SBD5CMH28')
    """
