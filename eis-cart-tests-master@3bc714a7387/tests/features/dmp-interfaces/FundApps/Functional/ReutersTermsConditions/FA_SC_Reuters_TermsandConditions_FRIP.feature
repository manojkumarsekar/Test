# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 26/03/2019      TOM-4401    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4401
#https://collaborate.intranet.asia/display/TOMR4/FA-IN-SMF-Reuters-DMP-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4401 @reuters_TnC @dmp_interfaces

Feature: TOM_4401 SSDR_INBOUND | Reuters Terms and Conditions |

  This is an OMDX check .We are creating an OMDX so that the Issuer (FINS) and Instrument are linked via the Fins Role/Issue Participant (FRIP) link

  Scenario: TC_1: Load Reuters Terms and Conditions file Reuters_TnC_Security_FRIP.csv

    Given I assign "Reuters_TnC_Security_FRIP.csv" to variable "RT_TNC_INPUT_FILE"
    And I assign "200" to variable "workflow.max.polling.time"
    And I assign "tests/test-data/dmp-interfaces/FundApps/Functional/ReutersTermsConditionsSecurity" to variable "testdata.path"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":

      | ${RT_TNC_INPUT_FILE} |

    When I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${RT_TNC_INPUT_FILE}          |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_2: Verifications for Fins/Role Issue Participant (FRIP)

    Then I expect value of column "VERIFY_FRIP_RTISSR" in the below SQL query equals to "1":


  """
	SELECT
    COUNT(*) AS VERIFY_FRIP_RTISSR
	FROM FT_T_FRIP
	WHERE INST_MNEM IN
	                  (
	                     SELECT INST_MNEM
	                     FROM FT_T_FIID
	                     WHERE FINS_ID = '101623525'
	                     AND END_TMS IS NULL
	                  )
    AND PRT_PURP_TYP IN  ('RTISSR')
    AND   END_TMS IS NULL
	"""

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory