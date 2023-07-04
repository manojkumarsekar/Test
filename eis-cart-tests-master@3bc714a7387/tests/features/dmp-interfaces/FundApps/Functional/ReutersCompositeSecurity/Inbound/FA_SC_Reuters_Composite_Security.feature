# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 23/03/2019      TOM-4352    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4352
#https://collaborate.intranet.asia/display/TOMR4/FA-IN-SMF-Reuters-DMP-Security-File
#Reuters Composite is a custom build to take in the security data attributes supported in the Composite template , these fields are not supported in the RT TnC OOB connector
#EISDEV-5220 14/01/2020: Added additional attributes check

@tom_4352 @dmp_fundapps_functional @fund_apps_reuters_composite @dmp_interfaces @tom_4497 @eisdev_5220

Feature: TOM_4352 Reuters Composite Connector data points verification

 # This feature file will test the data points which have been included as part of the custom build for Reuters. The fields in this custom connection are attributes of interest from FundApps perspective

  Scenario: TC_1: Clear old test data for Reuters and set up variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/ReutersCompositeSecurity" to variable "testdata.path"

    And I assign "200" to variable "workflow.max.polling.time"

    And I execute below query
    """
    ${testdata.path}/sql/ClearData_Reuters.sql
   """

  Scenario: TC_2: Load Reuters file REUTERS_COMPOSITE_DATE_CHECK.csv

    Given I assign "REUTERS_COMPOSITE_DATA_1.csv" to variable "RT_COMPOSITE_INPUT_FILE"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/ReutersCompositeSecurity" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RT_COMPOSITE_INPUT_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${RT_COMPOSITE_INPUT_FILE} |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE   |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_3: Data verification for Entity LEI : VERIFY_FIID_RTENTLEI

    Then I expect value of column "VERIFY_FIID_RTENTLEI" in the below SQL query equals to "1":

    """
	SELECT
    COUNT(*) AS VERIFY_FIID_RTENTLEI
	FROM FT_T_FIID
	WHERE INST_MNEM IN
	                  (
	                     SELECT INST_MNEM
	                     FROM FT_T_FIID
	                     WHERE FINS_ID = '38999'
	                     AND END_TMS IS NULL
	                  )
    AND FINS_ID_CTXT_TYP IN ('RTENTLEI')
    AND   END_TMS IS NULL
	"""

  Scenario: TC_4: Data verification for Country of Risk Primary : VERIFY_GUID_CNTRISKPRM

    Then I expect value of column "VERIFY_GUID_CNTRISKPRM" in the below SQL query equals to "1":
	"""
	SELECT
    COUNT(*) AS VERIFY_GUID_CNTRISKPRM
	FROM FT_T_FIGU
	WHERE INST_MNEM IN
	                  (
	                     SELECT INST_MNEM
	                     FROM FT_T_FIID
	                     WHERE FINS_ID = '38999'
	                     AND END_TMS IS NULL
	                  )
    AND FINS_GU_PURP_TYP IN ('RISKPRMY')
    AND   END_TMS IS NULL
	"""

  Scenario: TC_5: Data Verifications for Issue Statistics

  Following data verifications are for the following fields from Reuters Composite

  Total Voting Rights Treasury
  Total Voting Rights Listed
  Total Voting Rights Issued
  Total Voting Rights Outstanding

    Then I expect value of column "VERIFY_ISST" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS VERIFY_ISST FROM FT_T_ISST WHERE STAT_DEF_ID IN
    ('TOTVTRSY' , 'TOTVTLST' , 'TOTVTISS', 'VTRGTOUT',
    'VTRGTDEF', 'VTRGTUNL')AND INSTR_ID IN
    (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH0001010R16' AND END_TMS IS NULL)
     AND END_TMS IS NULL
    """

  Scenario: TC_6: Data Verifications for Issue Market Capitalization

  Following data verifications are for the following fields from Reuters Composite

  Debt Outstanding Total Amount Outstanding
  Market Capitalization
  Shares Outstanding
  Total Shares Outstanding
  Total Shares Treasury
  Total Shares Issued
  Total Shares Listed
  Total Issued Share Capital
  Listed Shares Issue Shares Amount
  Shares Amount

    Then I expect value of column "VERIFY_ISMC" in the below SQL query equals to "16":

  """
    SELECT COUNT(*) AS VERIFY_ISMC  FROM FT_T_ISMC WHERE CAPITAL_TYP IN
    ('RTDO' , 'RTMKCAP' , 'RTSO', 'RTTSHOUT','TOTSHTRS','TOTSHISS','TOTSHLIS', 'LISSHISS', 'TOISHCAP', 'LIS',
     'TVSHDFLT', 'TVSHISSU', 'TVSHLIST', 'TVSHOUTS', 'TVSHTREA', 'TVSHULST' )AND INSTR_ID IN
    (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH0001010R16' AND END_TMS IS NULL)
    AND END_TMS IS NULL
  """


  Scenario: TC_7: Load Reuters file REUTERS-COMPOSITE-FILE-2-IDMV-TOTSHISS.csv

    Given I assign "REUTERS-COMPOSITE-FILE-2-IDMV-TOTSHISS.csv" to variable "RT_COMPOSITE_INPUT_FILE_1"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/ReutersCompositeSecurity" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RT_COMPOSITE_INPUT_FILE_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${RT_COMPOSITE_INPUT_FILE_1} |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE     |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_8: Data Verifications for Issue Market Capitalization TotalSharesIssued

  Following data verifications are for the following fields from Reuters Composite

  Total Shares Issued

    Then I expect value of column "VERIFY_ISMC_TOTSHISS" in the below SQL query equals to "1":

  """
    SELECT COUNT(*) AS VERIFY_ISMC_TOTSHISS FROM FT_T_ISMC WHERE CAPITAL_TYP IN
    ('TOTSHISS')AND INSTR_ID IN
    (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'AU000000ORG5' AND END_TMS IS NULL)
    AND END_TMS IS NULL
  """