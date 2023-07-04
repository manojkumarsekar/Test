#https://jira.pruconnect.net/browse/EISDEV-7127
#Functional specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOM&title=3rd+Party+ETF+Duration+for+GAA#businessRequirements-goals

@gc_interface_risk_analytics @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_7127 @001_risk_analytics_load

Feature: Load attributes required to extract morning star Eff Duration file

  The purpose of this interface is to load below attributes required to filter securities
  to be published in Effective Duration file to Morning Star
  SEC_DESC2 - We are storing this attribute from F10. But the values coming in F29 are different hence storing from F29
  RISK_SOURCE & EFF_DUR

  Scenario: TC1: Initialize variables

    Given I assign "tests/test-data/dmp-interfaces/Security/MorningStarETFDuration/Inbound" to variable "testdata.path"
    And I assign "001_RiskAnalytics_EffectiveDuration_sm.xml" to variable "INPUT_F10_FILENAME"
    And I assign "001_RiskAnalytics_EffectiveDuration_f29.xml" to variable "INPUT_F29_FILENAME"

  Scenario:TC2: Load Security  file

    Given I process "${testdata.path}/inputfiles/${INPUT_F10_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_F10_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario:TC2: Load Risk analytics file

    Given I process "${testdata.path}/inputfiles/${INPUT_F29_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_F29_FILENAME}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Check if SEC_DESC2, RISK_SOURCE & EFF_DUR were stored in DMP

    Then I expect value of column "F29DESC2" in the below SQL query equals to "ETF-F":
    """
      SELECT ISS_NME AS F29DESC2 FROM FT_T_ISDE WHERE DESC_USAGE_TYP  = 'F29DESC2' AND END_TMS IS NULL AND INSTR_ID IN
      (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = 'SBMHXF667' AND END_TMS IS NULL)
    """

    Then I expect value of column "RISK_SOURCE" in the below SQL query equals to "BRS":
    """
      SELECT ORIG_DATA_PROV_ID AS RISK_SOURCE FROM FT_T_ISAN WHERE INSTR_ID IN
      (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = 'SBMHXF667' AND END_TMS IS NULL)
    """

    Then I expect value of column "EFF_DUR" in the below SQL query equals to ".0001":
    """
      SELECT EFF_DURATION_CRTE AS EFF_DUR FROM FT_T_ISAN WHERE INSTR_ID IN
      (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = 'SBMHXF667' AND END_TMS IS NULL)
    """