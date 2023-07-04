#https://jira.intranet.asia/browse/TOM-4125
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4445 @dmp_fundapps_functional @fund_apps @fund_apps_security

Feature: TOM_4445 SSDR_INBOUND | RCR| LBU Instrument | BOCI LBU Instrument with no Sedol and ISIN

  The data points which are common between the files have been verified in the feature file of MANDG , this feature file is created to verify data specific to LBU/RCR

	Scenario: TC_1: Clear old test data for BOCI and set up variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

      And I assign "200" to variable "workflow.max.polling.time"

	And I execute below query
    """
    UPDATE ft_t_isid set end_tms =sysdate-1 , start_tms = sysdate-1
    where instr_id in (select instr_id from ft_t_isid where iss_id ='BPM2F5HU4' and id_ctxt_typ = 'BOCICODE')
    and  id_ctxt_typ = 'BOCICODE'
    and end_tms is null
    and  last_chg_usr_id ='EIS_RCRLBU_DMP_SECURITY'
    """

  Scenario: TC_2: Load BOCI file ID_BOCIEISLINSTMT20181218.csv

    Given I assign "ID_BOCIEISLINSTMT20181218.csv" to variable "BOCI_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BOCI_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${BOCI_INPUT_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	AND JOB_STAT_TYP ='CLOSED'
	AND TASK_TOT_CNT = 1
	AND TASK_CMPLTD_CNT = 1
	AND TASK_SUCCESS_CNT = 1
	"""

    Scenario: TC_3: Data Verifications for BOCICODE

    #Check if ISID is created with data present in the test file  if BOCIDCODE is created
	#VERIFY MY DATA:
	Then I expect value of column "VERIFY_ISID_BOCI" in the below SQL query equals to "1":
	   """
	   SELECT COUNT(*) AS VERIFY_ISID_BOCI FROM FT_T_ISID
	   WHERE  ISS_ID = 'BPM2F5HU4'
       AND ID_CTXT_TYP IN ('BOCICODE')
       AND END_TMS IS NULL
	   """