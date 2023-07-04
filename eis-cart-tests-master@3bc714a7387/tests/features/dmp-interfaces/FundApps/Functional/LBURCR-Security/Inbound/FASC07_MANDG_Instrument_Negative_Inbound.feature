# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 08/02/2019      TOM-4125    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4125
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

#This feature is not stable and below scenarios are covered as part of other feature file i.e @01_inbound_rcr_mng,@tom-4639, hence removed all tags.
Feature: TOM_4125 SSDR_INBOUND | RCR| LBU Instrument | MNG RCR EQCH File

	The data points which are common between the files have been verified in the feature file of MANDG , this feature file is created to verify data specific to LBU/RCR

	Scenario: TC_1: Clear old test data and setup variables

		Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

        And I assign "200" to variable "workflow.max.polling.time"

		And I execute below query
    """
    ${testdata.path}/sql/Clear_data_Neg_EQCH.sql
    """

    Scenario: TC_2: Load MNG file MANG_EISL_INSTMT_NEG_TEST_EQCH.csv

   		 Given I assign "MANG_EISL_INSTMT_NEG_TEST_EQCH.csv" to variable "INPUT_NEG_FILENAME"

   		 Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

   		 And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
        | ${INPUT_NEG_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_NEG_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SECURITY |

	Then I extract new job id from jblg table into a variable "JOB_ID"

	And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

    Scenario: TC_3: Data Verifications for MANDG in EQCH

	#Check if EQCH is created with data present in the test file, since the incoming value is not present no row should get created
	#VERIFY MY DATA:
	 Then I expect value of column "VERIFY_NEG_EQCH" in the below SQL query equals to "0":
	 """
	 ${testdata.path}/sql/Verifying_EQCH_NEG_MANDG.sql
	"""