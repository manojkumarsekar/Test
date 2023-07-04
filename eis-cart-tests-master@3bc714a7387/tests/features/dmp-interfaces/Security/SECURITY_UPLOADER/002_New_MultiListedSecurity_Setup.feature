#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-5524 : Initial Version
#eisdev-6192 : Updated feature file with the enhaced mapping

@gc_interface_securities
@dmp_regression_unittest
@dmp_security_uploader @new_security_setup @esidev_5524 @esidev_6192
Feature: 002 | Security Uploader | New Multi Listed Security Setup
  Verify new security is setup from the Security Uploader and the data is mapped to the respective tables as per the mapping definition

  Scenario: End date Instruments in GC and VD DB

    Given I inactivate "B44DPG3" instruments in GC database
    And I inactivate "B44DPG3" instruments in VD database
    And I inactivate "BD5CMH2" instruments in GC database
    And I inactivate "BD5CMH2" instruments in VD database

  Scenario: Loading Securities using Security Uploader

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_Multilisted.xlsx" to variable "INPUT_FILENAME"

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Data verification in GC for ISSU
  Expect 1 valid instruments should get loaded into FT_T_ISSU table

    Then I expect value of column "issu_count_gc" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_gc from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id in('B44DPG3','BD5CMH2') and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in GC for ISID
  Expect 8 identifiers are created into FT_T_ISID table, EISSEC and ISIN without market
  BD5CMH2	SBD5CMH28 and ESLID1 with SZSC
  B44DPG3	SB44DPG32 and ESLID1 with XSHE

    Then I expect value of column "isid_count_gc" in the below SQL query equals to "8":
    """
    select count(*) as isid_count_gc from ft_t_isid
    where instr_id in (select instr_id from ft_t_isid where iss_id in('B44DPG3','BD5CMH2') and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in GC for MKIS
  Expect Two FT_T_MKIS should get populated

    Then I expect value of column "mkis_count_gc" in the below SQL query equals to "2":
    """
    select count(*) as mkis_count_gc from ft_t_mkis
    where instr_id in (select instr_id from ft_t_isid where iss_id in('B44DPG3','BD5CMH2') and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in VD for ISSU
  Expect 1 valid instruments should get loaded into FT_T_ISSU table

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "issu_count_vd" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_vd from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id in('B44DPG3','BD5CMH2') and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in VD for ISID
  Expect 5 identifiers are created into FT_T_ISID table, ISIN without market, BD5CMH2 and SBD5CMH28 with SZSC, B44DPG3 and SB44DPG32 with XSHE

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "isid_count_vd" in the below SQL query equals to "5":
    """
    select count(*) as isid_count_vd from ft_t_isid
    where instr_id in (select instr_id from ft_t_isid where iss_id in('B44DPG3','BD5CMH2') and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in VD for MKIS
  Expect Two FT_T_MKIS should get populated

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "mkis_count_vd" in the below SQL query equals to "2":
    """
    select count(*) as mkis_count_vd from ft_t_mkis
    where instr_id in (select instr_id from ft_t_isid where iss_id in('B44DPG3','BD5CMH2') and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """
