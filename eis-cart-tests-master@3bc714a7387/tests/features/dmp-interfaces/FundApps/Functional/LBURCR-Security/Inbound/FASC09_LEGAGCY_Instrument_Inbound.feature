# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 12/03/2019      TOM-4319    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4319
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4319 @dmp_fundapps_functional @fund_apps_security @dmp_interfaces

Feature: TOM_4319 SSDR_INBOUND | RCR| LBU Instrument | LEGACY LBU

  The data points which are common between the files have been verified in the feature file of LEGACY , this feature file is created to verify data specific to LBU/RCR

  Scenario: TC_1: Clear old test data for LEGACY and set up variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I assign "200" to variable "workflow.max.polling.time"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data_LEGACY.sql
    """

  Scenario: TC_2: Load LEGACY file LEGACY_EISL_INSTMT_2019123.csv

    Given I assign "LEGACY_EISL_INSTMT_2019123.csv" to variable "LEGACY_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LEGACY_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${LEGACY_INPUT_FILE}       |
      | MESSAGE_TYPE  | EIS_MT_LEGACY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_3:Verifications for Instrument_ID-Check if ISID is created with test file(Security_id,ISIN,SEDOL)

    Then I expect value of column "VERIFY_ISID_LAGACY" in the below SQL query equals to "3":
    """
	SELECT
    COUNT(*) AS VERIFY_ISID_LAGACY
	FROM FT_T_ISID
	WHERE INSTR_ID IN
	                  (
	                     SELECT INSTR_ID
	                     FROM FT_T_ISID
	                     WHERE ISS_ID = 'ESL6142386'
	                     AND END_TMS IS NULL
	                  )
    AND ID_CTXT_TYP IN ('ISIN','SEDOL','EISLSTID')
    AND   END_TMS IS NULL
	"""

  Scenario: TC_4:Verifications for ISSUE Classification-Check if ISCL is created with test file(Security_Instrument_Type)

    Then I expect value of column "VERIFY_ISCL_LAGACY" in the below SQL query equals to "1":
	"""
	SELECT
	COUNT(*) AS VERIFY_ISCL_LAGACY
    FROM FT_T_ISCL
    WHERE INSTR_ID IN
                      (
                         SELECT INSTR_ID
                         FROM FT_T_ISID
                         WHERE ISS_ID='ESL6142386'
                         AND END_TMS IS NULL
                      )
    and CL_VALUE ='CB'
    and INDUS_CL_SET_ID='LGYSECTYPE'
    and CLSF_PURP_TYP='LGYINTYP'
	"""

  Scenario: TC_5: Data Verifications for LEGACY ISSUE Description

    Then I expect value of column "VERIFY_ISSUE_DESC" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISSUE_DESC
    FROM FT_T_ISDE
    WHERE INSTR_ID IN
                        (
                            SELECT INSTR_ID
                            FROM FT_T_ISID
                            WHERE ISS_ID='ESL6142386'
                            AND END_TMS IS NULL
                        )
    AND DESC_USAGE_TYP='PRIMARY'
    """