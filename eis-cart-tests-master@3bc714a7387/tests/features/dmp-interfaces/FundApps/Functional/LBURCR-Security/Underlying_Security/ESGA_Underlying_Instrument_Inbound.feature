# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 17/04/2019      TOM-4504    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4504
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4504 @dmp_fundapps_functional @fund_apps_security @dmp_interfaces @tom_4504

Feature: TOM_4504 SSDR_INBOUND | RCR| LBU Instrument | ESGA LBU

  The data points which are common between the files have been verified in the feature file of ESGA , this feature file is created to verify data specific to LBU/RCR

	Scenario: TC_1: Clear old test data for ESGA and set up variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Underlying_security" to variable "testdata.path"

      And I assign "200" to variable "workflow.max.polling.time"

	And I execute below query
    """
    ${testdata.path}/sql/Clear_data_ESGA_Underlying.sql
    """

  Scenario: TC_2: Load ESGA file ESGA_Security_Underlying.csv

    Given I assign "ESGA_Security_Underlying.csv" to variable "ESGA_INPUT_FILE"
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Underlying_security" to variable "testdata.path"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ESGA_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_RCRLBU_DMP_ESGA_SECURITY                    |
      | FILE_PATTERN  | ${ESGA_INPUT_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_3:Verifications for Instrument_ID-Check if ISID is created with test file(Security_id,ISIN,SEDOL)

    Then I expect value of column "VERIFY_ISID_ESGA" in the below SQL query equals to "3":
    """
	SELECT
    count(*) as VERIFY_ISID_ESGA
	FROM FT_T_ISID
	WHERE INSTR_ID IN
	                  (
	                     SELECT INSTR_ID
	                     FROM FT_T_ISID
	                     WHERE ISS_ID = 'US8030542042'
	                     AND END_TMS IS NULL
	                  )
    AND ID_CTXT_TYP IN ('ISIN','SEDOL','ESGACODE')
    AND   END_TMS IS NULL
	"""

  Scenario: TC_4:Verifications for Underlying_id setup with the security id or not

    Then I expect value of column "VERIFY_UNDERLYING" in the below SQL query equals to "1":
	"""
	SELECT count(*) VERIFY_UNDERLYING
	FROM fT_T_riss WHERE rld_iss_feat_id in
                                             (
                                                 SELECT rld_iss_feat_id
                                                 FROM fT_T_ridf
                                                 WHERE instr_id in (SELECT instr_id FROM ft_T_isid WHERE iss_id='US8030542042'and end_tms is null)
                                                 and end_tms is null
                                              )

    and instr_id in (SELECT instr_id FROM ft_T_isid WHERE iss_id='DE0007164600'  and end_tms is null)
    and iss_part_rl_typ='UNDLYING'and Last_chg_usr_id='EIS_RCRLBU_DMP_SECURITY'
    """
