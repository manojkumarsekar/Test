# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 08/02/2019      TOM-4125    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4125
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4125 @fund_apps @fund_apps_security @dmp_interfaces @tom_4319 @fund_apps_security_jnam

Feature: TOM_4125 SSDR_INBOUND | RCR| LBU Instrument |JNAM RCR

  The data points which are common between the files have been verified in the feature file of MANDG , this feature file is created to verify data specific to LBU/RCR

  Scenario: TC_1: Clear old test data for JNAM and setup variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I assign "200" to variable "workflow.max.polling.time"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data_JNAM.sql
    """

  Scenario: TC_2: Load JNAM-PPMG file JNAM_EISL_INSTMT_20181218.csv

    Given I assign "JNAM_EISL_INSTMT_20181218.csv" to variable "ESJNAM_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ESJNAM_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${ESJNAM_INPUT_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_JNAM_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""
  Scenario: TC_3: Data Verifications for JNAM-PPMG

     #Check if ISID is created with data present in the test file (Security_id,ISIN,SEDOL) if PPMJNAMCDE is created
  #VERIFY MY DATA:
    Then I expect value of column "VERIFY_ISID_JNAM" in the below SQL query equals to "4":
	   """
	   ${testdata.path}/sql/Verifying_ISID_JNAM.sql
	   """
 #Check if ISCL is created with data present in the test file(Security_Instrument_Type)
  #VERIFY MY DATA:
    Then I expect value of column "VERIFY_ISCL_JNAM" in the below SQL query equals to "1":
	 """
	 ${testdata.path}/sql/Verifying_ISCL_JNAM.sql
	 """

  Scenario: TC_4: Verify PPMJNAMCDE created with market same as SEDOL
    #Checking with market assigned to existing SEDOL
    Then I expect value of column "VERIFY_ISID_MARKET" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS VERIFY_ISID_MARKET FROM FT_T_ISID
      WHERE ID_CTXT_TYP in ('SEDOL','PPMJNAMCDE')
      AND ISS_ID in ('060505104','2295677')
      AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='XNYS' and end_tms is null)
      AND END_TMS is NULL
      """

    Then I expect value of column "VERIFY_MKIS" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS VERIFY_MKIS FROM FT_T_MKIS
      WHERE INSTR_ID in (SELECT INSTR_ID from FT_T_ISID where ISS_ID='060505104' and ID_CTXT_TYP='PPMJNAMCDE' and END_TMS is null)
      AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='XNYS' and end_tms is null)
      AND END_TMS is null
      """

    Then I expect value of column "VERIFY_MIXR" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS VERIFY_MIXR FROM FT_T_MIXR
      WHERE MKT_ISS_OID IN
      (SELECT MKT_ISS_OID from FT_T_MKIS where INSTR_ID in (SELECT INSTR_ID from FT_T_ISID where ISS_ID='060505104' and ID_CTXT_TYP='PPMJNAMCDE' and END_TMS is null))
      AND ISID_OID in (SELECT ISID_OID FROM FT_T_ISID WHERE ID_CTXT_TYP in ('SEDOL','PPMJNAMCDE') AND ISS_ID in ('060505104','2295677') AND MKT_OID in (SELECT MKT_OID from FT_T_MKID where MKT_ID_CTXT_TYP='MIC' and MKT_ID='XNYS' and end_tms is null) AND END_TMS is NULL)
      AND END_TMS is null
      """
