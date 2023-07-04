#https://jira.pruconnect.net/browse/EISDEV-6478
#Functional specification : https://collaborate.pruconnect.net/display/EISTT/Total+NAV%7CAladdin+BPP%7CTMBAM%2CTFUND

@eisdev_6478 @th_uat_initial_setup
Feature: Create UAT Portfolios for Thailand and map to ThaiId

  The purpose of this interface is to crate the UAT portfolio for Thailand and map to ThaiId after UAT refresh.

  We tests the following Scenario with this feature file.
  1.Scenario TC2: Create UAT portfolios for Thailand alogwith ThaiID

  Scenario: TC1: Initialize variables and Deactivate Existing test maintain clean state before executing tests

    Given I assign "tests/test-data/dmp-interfaces/Thailand/UATSetup/Inbound" to variable "TESTDATA_PATH_INBOUND"

    # Portfolio Uploader variable
    And I assign "001_BRS_DMP_UAT_PortfolioCreation_PreRequisite.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"

     And I execute below query to "set up FPRO"
	"""
    update ft_t_fpro set FINS_PRO_ID = 'TestAutomation@eastspring.com', PRO_DESIGNATION_TXT = 'PM' where fpro_oid = 'Ec6Q58Mj81';
    commit
    """

  Scenario:TC2: Create portfolios using uploader

    Given I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${INPUT_PROTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "18"


  Scenario:TC3 Re-set FPRO

    Given I execute below query to "reset FPRO"
	"""
	update ft_t_fpro set FINS_PRO_ID = 'azhar.arayilakath@eastspring.com' where fpro_oid = 'Ec6Q58Mj81';
	commit
    """