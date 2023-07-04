# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 27/03/2019      TOM-4404    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4404
#https://collaborate.intranet.asia/display/TOMR4/FA-IN-SMF-Reuters-DMP-Security-File
#Mapping the issue usage type for mdxs

@tom_4404 @dmp_fundapps_functional  @dmp_interfaces

Feature: TOM_4401 SSDR_INBOUND | Reuters Terms and Conditions |

  Scenario: TC_1: Load BRS file

    Given I assign "BRS_ONE_RECORD.xml" to variable "BRS_INPUT_FILE"
    Given I assign "BNP_ONE_RECORD.out" to variable "BNP_ONE_RECORD"
    Given I assign "RDM_ONE_RECORD.CSV" to variable "RDM_ONE_RECORD"
    Given I assign "BRS_ORDERS_ONE_RECORD.xml" to variable "BRS_ORDERS_ONE_RECORD"


    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Security" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":

      | ${BRS_INPUT_FILE} |
      | ${BNP_ONE_RECORD} |
      | ${RDM_ONE_RECORD} |
      | ${BRS_ORDERS_ONE_RECORD} |

    And I assign "200" to variable "workflow.max.polling.time"
    
    And I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${BRS_INPUT_FILE}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    And I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${BNP_ONE_RECORD}       |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY     |

    And I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${RDM_ONE_RECORD}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_SECURITY     |

    And I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${BRS_ORDERS_ONE_RECORD}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS     |



#    Then I extract new job id from jblg table into a variable "JOB_ID"
#
#    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "2":
#    """
#	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
#	"""

    Then I expect value of column "VERIFY_BRS_USGTYP" in the below SQL query equals to "2":

  """
	SELECT
    COUNT(*) AS VERIFY_BRS_USGTYP
	FROM FT_T_ISID
	WHERE ISS_ID IN ( '2026361', 'AFL.N') AND ID_CTXT_TYP IN ('SEDOL' , 'RIC') AND ISS_USAGE_TYP IS NOT NULL
    AND   END_TMS IS NULL
	"""

    Then I expect value of column "VERIFY_BNP_USGTYP" in the below SQL query equals to "1":

  """
	SELECT
    COUNT(*) AS VERIFY_BNP_USGTYP
	FROM FT_T_ISID
	WHERE ISS_ID IN ( 'BFXF3N0') AND ID_CTXT_TYP IN ('SEDOL') AND ISS_USAGE_TYP IS NOT NULL
    AND   END_TMS IS NULL
	"""

    Then I expect value of column "VERIFY_RDM_USGTYP" in the below SQL query equals to "1":

  """
	SELECT
    COUNT(*) AS VERIFY_RDM_USGTYP
	FROM FT_T_ISID
	WHERE ISS_ID IN ( 'BYMPYP3') AND ID_CTXT_TYP IN ('SEDOL') AND ISS_USAGE_TYP IS NOT NULL
    AND   END_TMS IS NULL
	"""

    Then I expect value of column "VERIFY_BRS_ORDER_USGTYP" in the below SQL query equals to "1":

  """
	SELECT
    COUNT(*) AS VERIFY_BRS_ORDER_USGTYP
	FROM FT_T_ISID
	WHERE ISS_ID IN ( 'B1V74X7') AND ID_CTXT_TYP IN ('SEDOL') AND ISS_USAGE_TYP IS NOT NULL
    AND   END_TMS IS NULL
	"""