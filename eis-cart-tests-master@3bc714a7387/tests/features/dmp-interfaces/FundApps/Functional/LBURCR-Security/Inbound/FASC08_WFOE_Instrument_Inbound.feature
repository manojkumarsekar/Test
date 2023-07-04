# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 08/03/2019      TOM-4321    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4321
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

#This feature is not stable and below scenarios are covered as part of other feature file i.e @11_inbound_rcr_wfoe,@tom-4639 , hence removed all tags.

Feature: TOM_4321 SSDR_INBOUND | RCR| LBU Instrument | WFOE RCR

	The data points which are common between the files have been verified in the feature file of WFOE , this feature file is created to verify data specific to LBU/RCR

	Scenario: TC_1: Clear old test data and setup variables

		Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

        And I assign "200" to variable "workflow.max.polling.time"

		And I execute below query
    """
    ${testdata.path}/sql/Clear_data_WFOE.sql
    """

    Scenario: TC_2: Load WFOE file WFOE_EISL_INSTMT_20181218.csv

   		 Given I assign "WFOE_EISL_INSTMT_20181218.csv" to variable "INPUT_FILENAME"

   		 Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

   		 And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
        | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_WFOE_DMP_SECURITY |

	Then I extract new job id from jblg table into a variable "JOB_ID"

	And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

    Scenario: TC_3: Data Verifications for WFOE

    #Check if ISID is created with data present in the test file
	#VERIFY MY DATA:
	Then I expect value of column "VERIFY_ISID_WFOE" in the below SQL query equals to "9":
	   """
	    SELECT COUNT(*) AS VERIFY_ISID_WFOE FROM FT_T_ISID WHERE ID_CTXT_TYP IN ('WFOECODE') AND END_TMS IS NULL
	   """

	#Check if INCL is created with data present in the test file(Security_Instrument_Type)
	#VERIFY MY DATA:
	 Then I expect value of column "VERIFY_ISCL" in the below SQL query equals to "9":
	 """
	 SELECT COUNT(*) AS VERIFY_ISCL FROM FT_T_ISCL WHERE INDUS_CL_SET_ID = 'WFOESCTYP' AND END_TMS IS NULL
	"""

  Scenario: TC_4: Verify WFOECODE created with market same as SEDOL
       #Checking with market assigned to existing SEDOL
    Then I expect value of column "VERIFY_ISID_MARKET" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS VERIFY_ISID_MARKET FROM FT_T_ISID
      WHERE ID_CTXT_TYP in ('SEDOL','WFOECODE')
      AND ISS_ID in ('002027.SZ','B02FVZ4')
      AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='XSHE' and end_tms is null)
      AND END_TMS is NULL
      """

    Then I expect value of column "VERIFY_MKIS" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS VERIFY_MKIS FROM FT_T_MKIS
      WHERE INSTR_ID in (SELECT INSTR_ID from FT_T_ISID where ISS_ID='002027.SZ' and ID_CTXT_TYP='WFOECODE' and END_TMS is null)
      AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='XSHE' and end_tms is null)
      AND END_TMS is null
      """

    Then I expect value of column "VERIFY_MIXR" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS VERIFY_MIXR FROM FT_T_MIXR
      WHERE MKT_ISS_OID IN
      (SELECT MKT_ISS_OID from FT_T_MKIS where INSTR_ID in (SELECT INSTR_ID from FT_T_ISID where ISS_ID='002027.SZ' and ID_CTXT_TYP='WFOECODE' and END_TMS is null))
      AND ISID_OID in (SELECT ISID_OID FROM FT_T_ISID WHERE ID_CTXT_TYP in ('SEDOL','WFOECODE') AND ISS_ID in ('002027.SZ','B02FVZ4') AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='XSHE' and end_tms is null) AND END_TMS is NULL)
      AND END_TMS is null
      """