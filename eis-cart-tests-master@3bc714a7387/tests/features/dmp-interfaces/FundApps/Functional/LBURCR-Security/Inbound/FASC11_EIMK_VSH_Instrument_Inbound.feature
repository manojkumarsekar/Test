# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 08/02/2019      TOM-4125    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4125
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4445 @fund_apps @dmp_fundapps_functional @fund_apps_security

Feature: Verifying VSH for Reuters and MNG
  Loading MNG file and verifying it gets overwritten by Reuters data

  Scenario: TC_1: Clear old test data for MNG and reuters

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I execute below query
    """
    UPDATE ft_t_isid set end_tms =sysdate-1 , start_tms = sysdate-1
    where instr_id in (select instr_id from ft_t_isid where iss_id ='7333378' and id_ctxt_typ = 'MNGCODE')
    and end_tms is null
    and  (last_chg_usr_id ='EIS_RCRLBU_DMP_SECURITY' or last_chg_usr_id ='TRMCONDT');
    """

  Scenario: TC_2: Load MNG file VSH_MANGEISLINSTMT20190326.csv

    Given I assign "VSH_MANGEISLINSTMT20190326.csv" to variable "MNG_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${MNG_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${MNG_INPUT_FILE}       |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_3: Data Verifications for MNG - MNGCODE and SEDOL with dummy market

    Then I expect value of column "VERIFY_ISID_ESKOR_DUMMY" in the below SQL query equals to "1":
	   """
       Select count(*) as VERIFY_ISID_ESKOR_DUMMY from FT_T_ISID
       where iss_id ='7333378'
       and id_ctxt_typ = 'MNGCODE'
       and end_tms is null
       AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='ZZZZ' and end_tms is null)
	   """

    Then I expect value of column "VERIFY_ISID_SEDOL_DUMMY" in the below SQL query equals to "1":
	   """
       Select count(*) as VERIFY_ISID_SEDOL_DUMMY from FT_T_ISID
       where iss_id ='7333378'
       and id_ctxt_typ = 'SEDOL'
       and end_tms is null
       AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='ZZZZ' and end_tms is null)
	   """

  Scenario: TC_4: Load Reuters file VSH_gs_com00003678.csv

    Given I assign "VSH_gs_com00003678.csv" to variable "RT_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RT_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${RT_INPUT_FILE}       |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_5: Data Verifications for Reuters - MNGCODE and SEDOL with new market

    Then I expect value of column "VERIFY_ISID_ESKOR_NOTDUMMY" in the below SQL query equals to "0":
	   """
       Select count(*) as VERIFY_ISID_ESKOR_NOTDUMMY from FT_T_ISID
       where iss_id ='7333378'
       and id_ctxt_typ = 'MNGCODE'
       and end_tms is null
       AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='ZZZZ' and end_tms is null)
	   """

    Then I expect value of column "VERIFY_ISID_SEDOL_NOTDUMMY" in the below SQL query equals to "0":
	   """
       Select count(*) as VERIFY_ISID_SEDOL_NOTDUMMY from FT_T_ISID
       where iss_id ='7333378'
       and id_ctxt_typ = 'SEDOL'
       and end_tms is null
       AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='ZZZZ' and end_tms is null)
	   """

  Scenario: TC_6: Reload MNG file VSH_MANGEISLINSTMT20190326.csv

    Given I assign "VSH_MANGEISLINSTMT20190326.csv" to variable "MNG_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${MNG_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${MNG_INPUT_FILE}       |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_7: Data Verifications for MNG - MNGCODE and SEDOL with new market

    Then I expect value of column "VERIFY_ISID_ESKOR_NOTDUMMY" in the below SQL query equals to "0":
	   """
       Select count(*) as VERIFY_ISID_ESKOR_NOTDUMMY from FT_T_ISID
       where iss_id ='7333378'
       and id_ctxt_typ = 'MNGCODE'
       and end_tms is null
       AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='ZZZZ' and end_tms is null)
	   """

    Then I expect value of column "VERIFY_ISID_SEDOL_NOTDUMMY" in the below SQL query equals to "0":
	   """
       Select count(*) as VERIFY_ISID_SEDOL_NOTDUMMY from FT_T_ISID
       where iss_id ='7333378'
       and id_ctxt_typ = 'SEDOL'
       and end_tms is null
       AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='ZZZZ' and end_tms is null)
	   """
