#https://jira.pruconnect.net/browse/EISDEV-6245
#https://jira.pruconnect.net/browse/EISDEV-6279
#https://jira.pruconnect.net/browse/EISDEV-6263
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-25+Th.TMBAM.Price%28i.e+NAV_Per_Unit%29+from+TMBAM_HIPORT_FA+-+DMP
#Functional specification : https://collaborate.pruconnect.net/display/EISTOMR4/Th.Aldn-25+Th.TMBAM.Price%28i.e+NAV_Per_Unit%29+from+TMBAM_HIPORT_FA+-+DMP

# EISDEV-7003 Changes --START--
# Change Notification ID to 60037 for missing EISLSTID
# EISDEV-7003 Changes --END--

@gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_6245 @eisdev_6279 @eisdev_6263 @003_tmbam_nav_price_load @dmp_thailand_price @dmp_thailand
@eisdev_7003

Feature: TMBAM NAV Load for Thailand

  This feature tests the below scenarios related to loading of TMBAM NAV Per Unit file
  1. Record loading fails due too missing EISLSTID in ISID table for the security used

  Scenario: TC1: Initialize variables and Deactivate Existing EISLSTID for the security

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Inbound" to variable "testdata.path"

    # Portfolio Uploader variable
    And I assign "003_Th.Aldn-25_TMBAM_DMP_FA_NAV_PRICE_Portfolio_Creation_Prerequisite.xlsx" to variable "PORTFOLIO_INPUT_FILENAME"

    # NAV Load Variables
    And I assign "003_Th.Aldn-25_TMBAM_DMP_NAV.xml" to variable "NAV_INPUT_FILENAME"
    And I assign "003_Th.Aldn-25_TMBAM_DMP_NAV_Template.xml" to variable "NAV_INPUT_TEMPLATENAME"

    #Generate Sys Date and assign to variable
    And I generate value with date format "dd/MM/YYYY" and assign to variable "VAR_SYSDATE"

    #End date the ID_CTXT_TYP = EISLSTID for the security to inactivate only EISLSTID keeping other identifiers active
    And I execute below query to "inactivate only EISLSTID keeping other identifiers active"
	"""
    update ft_t_isid set end_tms = SYSDATE-1 where instr_id = 'efvNy<nGG2' and ID_CTXT_TYP = 'EISLSTID';
    commit
    """

  Scenario:TC2: Create portfolio and security releationship(AUT) using portfolio uploader

    When I process "${testdata.path}/testdata/${PORTFOLIO_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario:TC3: Load TMBAM NAV File

    Given I create input file "${NAV_INPUT_FILENAME}" using template "${NAV_INPUT_TEMPLATENAME}" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${NAV_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${NAV_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EITH_MT_TMBAM_DMP_FA_NAV_PRICE |
      | BUSINESS_FEED |                                |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario:TC4: Verify the failure count and exception message

    Then I expect workflow is processed in DMP with success record count as "0"

    And partial record count as "1"

  Scenario:TC5: Verify the exception message due to missing EISLSTID

    Then I expect value of column "MISSING_EISLSTID_EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS MISSING_EISLSTID_EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
     AND notfcn_id = '60037'
    """