# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/04/2019      TOM-4454   First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4454
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4454 @dmp_fundapps_functional @fund_apps_security @dmp_interfaces @tom_4454 @fund_apps_security_wfoe

Feature: TOM_4321 SSDR_INBOUND | RCR| LBU Instrument | WFOE RCR

  The data points which are common between the files have been verified in the feature file of WFOE , this feature file is created to verify data specific to LBU/RCR

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I assign "200" to variable "workflow.max.polling.time"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data_WFOE_1.sql
    """

  Scenario: TC_2: Load WFOE file WFOEEISLINSTMT20190329.csv

    Given I assign "WFOEEISLINSTMT20190329.csv" to variable "INPUT_FILENAME"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_WFOE_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT
	FROM FT_T_JBLG
	WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_3: Verify WFOECODE For PREF_ISS_NME

    Then I expect value of column "VERIFY_PREF_ISSU_NME" in the below SQL query equals to "1":
	"""
      select count(*) as VERIFY_PREF_ISSU_NME
      from ft_T_issu
      where PREF_ISS_NME='Chengdu Taihe health technolo'
      and instr_id in (
                        select instr_id
                        from ft_T_isid
                        where id_ctxt_typ='WFOECODE'
                        and iss_id='000790.SZ'
                        and end_tms is null
                      )
      AND END_TMS IS NULL
	"""

  Scenario: TC_4: Verify WFOECODE For PREF_ISS_DESC

    Then I expect value of column "CHECKPREF_DESC_NME" in the below SQL query equals to "1":
	"""
      select count(*)as CHECKPREF_DESC_NME
      from ft_T_issu
      where PREF_ISS_DESC='Chengdu Taihe health technolo' and
      instr_id in (
                        select instr_id
                        from ft_T_isid
                        where id_ctxt_typ='WFOECODE'
                        and iss_id='000790.SZ'
                        and end_tms is null
                      )
      AND END_TMS IS NULL
	"""
  Scenario:TC_5: Verify WOFECODE for ETF Check

    Then I expect value of column "VERIFY_WFOE_ETF" in the below SQL query equals to "1":
	"""
    select count(*)as  VERIFY_WFOE_ETF
    from ft_T_iscl where cl_value='ETF'
    and INDUS_CL_SET_ID='WFOESCTYP'
    and instr_id in (
                        select instr_id
                        from ft_T_isid
                        where id_ctxt_typ='WFOECODE'
                        and iss_id='511990.SH'
                        and end_tms is null
                      )
     and end_tms is null
	"""
