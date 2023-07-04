#https://jira.pruconnect.net/browse/EISDEV-6338
#This feature helps to validate creation of ALTCRTSID from CRTSID

@gc_interface_portfolios
@dmp_regression_unittest
@eisdev_6338 @create_altcrtsid @eisdev_6725
Feature: Create ALTCRTSID from CRTSID

  The purpose of this interface is validate creation of ALTCRTSID from CRTSID.

  Scenario: TC1: Initialize variables and Deactivate Existing test maintain clean state before executing tests

    Given I assign "tests/test-data/dmp-interfaces/Portfolio/Inbound" to variable "TESTDATA_PATH_INBOUND"
    And I assign "001_AltCrtsID_creation_from_portfolio_uploader.xlsx" to variable "INPUT_PORTFOLIO_FILENAME"
    And I assign "001_Create_New_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER"

    And I execute below query to "inactivate existing alt_crts_id"
    """
    update ft_t_acid set end_tms =sysdate where end_tms is null and acct_id_ctxt_typ='ALTCRTSID' and acct_id in
    (select acct_id from ft_t_acid where acct_alt_id='36' and acct_id_ctxt_typ='CRTSID');
    """

  Scenario:TC3: Create new portfolio with CRTSID 30

    Given I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${PORTFOLIO_UPLOADER}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPLOADER}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "1"
    And fail record count as "0"


  Scenario:TC2: Create ALTCRTSID from CRTSID

    Given I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${INPUT_PORTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_PORTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "1"
    And fail record count as "0"



