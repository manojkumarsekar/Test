#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#eisdev-5524 : Initial Version
#eisdev-6192 : Updated feature file with the enhaced mapping

@gc_interface_securities
@dmp_regression_unittest
@dmp_security_uploader @new_security_setup @esidev_5524 @esidev_6192
Feature: 001 | Security Uploader | New Security Setup
  Verify new security is setup from the Security Uploader and the data is mapped to the respective tables as per the mapping definition

  Scenario: End date Instruments in GC and VD DB

    Given I inactivate "BD838X0" instruments in GC database
    Given I inactivate "BD838X0" instruments in VD database

  Scenario: Loading Securities using Security Uploader

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER" to variable "TESTDATA_PATH"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_New_Security_Setup.xlsx" to variable "INPUT_FILENAME"

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification in GC for ISSU
  Expect 1 valid instruments should get loaded into FT_T_ISSU table

    Then I expect value of column "issu_count_gc" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_gc from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BD838X0' and end_tms is null)
    and iss_typ = 'BOND'
    and PREF_ISS_NME = 'NK KAZMUNAYGAZ AO'
    and DENOM_CURR_CDE = 'USD'
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in GC for ISID
  Expect 1 valid instruments should get loaded into FT_T_ISID table

    Then I expect value of column "isid_count_gc" in the below SQL query equals to "5":
    """
    select count(*) as isid_count_gc from ft_t_isid
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BD838X0' and end_tms is null)
    and id_ctxt_typ in ('BCUSIP','CUSIP','EISLSTID','EISSECID','SEDOL')
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in GC for ISCL
  Expect FT_T_ISCL should get populated with cl value CB

    Then I expect value of column "cl_value_gc" in the below SQL query equals to "CB":
    """
    select cl_value as cl_value_gc from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BD838X0' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

  Scenario: Data verification in GC for MKIS
  Expect FT_T_MKIS should get populated with curr USD, lot size 0 and MIC ZZZZ

    Then I expect value of column "mkis_count_gc" in the below SQL query equals to "1":
    """
    select count(*) as mkis_count_gc from ft_t_mkis mkis, ft_t_isid isid, ft_t_mkid mkid
    where mkis.mkt_oid = mkid.mkt_oid
    and mkis.instr_id = isid.instr_id
    and isid.iss_id = 'BD838X0'
    and isid.end_tms is null
    and mkis.end_tms is null
    and mkid.end_tms is null
    and mkid.MKT_ID = 'ZZZZ'
    and mkid.MKT_ID_CTXT_TYP = 'MIC'
    and mkis.RND_LOT_SZ_CQTY= 0
    and mkis.TRDNG_CURR_CDE = 'USD'
    and mkis.LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(mkis.START_TMS) = trunc(sysdate)
    """

  Scenario: Verify Lock is not applied to the new security as APPLY_LOCK is not set Y
  Expect no OVRC record is created

    Then I expect value of column "ovrc_count" in the below SQL query equals to "0":
    """
    select count(*) as ovrc_count
    from ft_t_ovrc
    where OVR_REF_OID in
    (select instr_id from ft_t_isid
    where iss_id = 'Y4596HAD9')
    """

  Scenario: Data verification in VD for ISSU
  Expect 1 valid instruments should get loaded into FT_T_ISSU table

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "issu_count_vd" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_vd from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BD838X0' and end_tms is null)
    and iss_typ = 'BOND'
    and PREF_ISS_NME = 'NK KAZMUNAYGAZ AO'
    and DENOM_CURR_CDE = 'USD'
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in VD for ISID
  Expect 1 valid instruments should get loaded into FT_T_ISID table

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "isid_count_vd" in the below SQL query equals to "3":
    """
    select count(*) as isid_count_vd from ft_t_isid
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BD838X0' and end_tms is null)
    and id_ctxt_typ in ('BCUSIP','CUSIP','EISLSTID','EISSECID','SEDOL')
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Data verification in VD for ISCL
  Expect ISCL should get populated into FT_T_ISCL table with cl value CB

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "cl_value_vd" in the below SQL query equals to "CB":
    """
    select cl_value as cl_value_vd from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BD838X0' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

  Scenario: Data verification in VD for MKIS
  Expect FT_T_MKIS should get populated with curr USD and MIC ZZZZ

    Given I set the database connection to configuration "dmp.db.VD"

    Then I expect value of column "mkis_count_vd" in the below SQL query equals to "1":
    """
    select count(*) as mkis_count_vd from ft_t_mkis mkis, ft_t_isid isid, ft_t_mkid mkid
    where mkis.mkt_oid = mkid.mkt_oid
    and mkis.instr_id = isid.instr_id
    and isid.iss_id = 'BD838X0'
    and isid.end_tms is null
    and mkis.end_tms is null
    and mkid.end_tms is null
    and mkid.MKT_ID = 'ZZZZ'
    and mkid.MKT_ID_CTXT_TYP = 'MIC'
    and mkis.TRDNG_CURR_CDE = 'USD'
    and mkis.LAST_CHG_USR_ID = 'EIS_DMP_SECURITY_MASTER_UPLOADER'
    and trunc(mkis.START_TMS) = trunc(sysdate)
    """