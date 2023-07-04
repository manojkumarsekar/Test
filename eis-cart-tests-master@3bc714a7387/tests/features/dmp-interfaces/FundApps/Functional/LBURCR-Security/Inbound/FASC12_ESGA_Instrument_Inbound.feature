# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 15/04/2019      TOM-4447    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4447
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4447 @dmp_fundapps_functional @fund_apps_security @dmp_interfaces  @fund_apps_security_esga

Feature: TOM_4447 SSDR_INBOUND | RCR| LBU Instrument | ESGA LBU

  The data points which are common between the files have been verified in the feature file of ESGA , this feature file is created to verify data specific to LBU/RCR

  Scenario: TC_1: Clear old test data for ESGA and set up variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"
    And I assign "200" to variable "workflow.max.polling.time"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data_ESGA.sql
    """

  Scenario: TC_2: Load ESGA file ESGAEISLINSTMT20181218_test.csv

    Given I assign "ESGAEISLINSTMT20181218_test.csv" to variable "ESGA_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ESGA_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${ESGA_INPUT_FILE}       |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_3: Check if ISID is created with data present in the test file (Security_id,ISIN,SEDOL) if ESGACODE is created

    Then I expect value of column "VERIFY_ISID_ESGA" in the below SQL query equals to "3":

    """
    SELECT COUNT(*) AS VERIFY_ISID_ESGA
    FROM FT_T_ISID
    WHERE INSTR_ID IN
                      (
                          SELECT INSTR_ID
                          FROM FT_T_ISID
                          WHERE ISS_ID = 'FR0000120644'
                          AND END_TMS IS NULL
                      )
    AND ID_CTXT_TYP IN ('ISIN','SEDOL','ESGACODE')
    AND END_TMS IS NULL
    """

  Scenario: TC_4:Check if ISCL is created with data present in the test file(Security_Instrument_Type)

    Then I expect value of column "VERIFY_ISCL_ESGA" in the below SQL query equals to "1":
	 """
	SELECT COUNT(*) AS VERIFY_ISCL_ESGA
    FROM FT_T_ISCL
    WHERE INSTR_ID IN
                      (
                          SELECT INSTR_ID
                          FROM FT_T_ISID
                          WHERE ISS_ID='FR0000120644'
                          AND END_TMS IS NULL
                      )
    and CL_VALUE ='COM'
    and INDUS_CL_SET_ID='ESGASCTYPE'
    and CLSF_PURP_TYP='ESGASCTYPE'
	"""

  Scenario: TC_5: Verify ESGACODE created with market same as SEDOL

    Then I expect value of column "VERIFY_ISID_MARKET" in the below SQL query equals to "2":
    """
     SELECT COUNT(*) AS VERIFY_ISID_MARKET
     FROM FT_T_ISID
     WHERE ID_CTXT_TYP in ('SEDOL','ESGACODE')
     AND ISS_ID in ('BVLZX12','US29444U7000')
     AND MKT_OID in
                      (
                        SELECT MKT_OID
                        from FT_T_MKID
                        where MKT_ID_CTXT_TYP='MIC'
                        and MKT_ID='XNAS'
                        and end_tms is null
                      )
     AND END_TMS is NULL
    """

    Then I expect value of column "VERIFY_MKIS" in the below SQL query equals to "1":
    """
    SELECT count(*) As VERIFY_MKIS
    FROM FT_T_MKIS
    WHERE INSTR_ID in
                      (
                        SELECT INSTR_ID
                        from FT_T_ISID
                        where ISS_ID='US29444U7000'
                        and ID_CTXT_TYP='ESGACODE'
                        and END_TMS is null
                      )
    AND MKT_OID in
                    (
                      SELECT MKT_OID
                      from FT_T_MKID
                      where MKT_ID_CTXT_TYP='MIC'
                      and MKT_ID='XNAS' and end_tms is null
                    )
    AND END_TMS is null
    """

    Then I expect value of column "VERIFY_MIXR" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_MIXR FROM FT_T_MIXR
    WHERE MKT_ISS_OID IN
                        (
                           SELECT MKT_ISS_OID
                           from FT_T_MKIS
                            where INSTR_ID in (
                                                  SELECT INSTR_ID
                                                  from FT_T_ISID
                                                  where ISS_ID='US29444U7000'
                                                  and ID_CTXT_TYP='ESGACODE'
                                                  and END_TMS is null
                                               )
                        )
    AND ISID_OID in (
                        SELECT ISID_OID
                        FROM FT_T_ISID
                        WHERE ID_CTXT_TYP in ('SEDOL','ESGACODE')
                        AND ISS_ID='US29444U7000'
                        AND MKT_OID in (
                                          SELECT MKT_OID from FT_T_MKID
                                          where MKT_ID_CTXT_TYP='MIC'
                                          and MKT_ID='XNAS'
                                          and end_tms is null
                                        )
                        AND END_TMS is NULL
                    )
    AND END_TMS is null
    """
