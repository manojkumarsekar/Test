@th_uat_tfund_crtsId_portgroup_update
Feature: TFUND Portfolio Update and Group Creation

  The purpose of this interface is to create ALTCRTSID, Update CRTSID and Create the portfolio group for TFUND UAT

  We tests the following Scenario with this feature file.
  1. Create ALTCRTSID using Portfolio Uploader
  2, Update CRTSID from Number(i.e Tfund CRTS Code is currently number) to String(i.e BRS CRTS code is String)
  3, Create the protfolio groups

  Scenario: TC1: Initialize variables
    Given I assign "tests/test-data/dmp-interfaces/Thailand/UATSetup/Inbound" to variable "TESTDATA_PATH_INBOUND"
    And I assign "002_1_AltCrtsID_update_portfolio_uploader_TFUND_0.4_08072020.xlsx" to variable "ALTCRTSID_INPUT_PROTFOLIO_FILENAME"
    And I assign "002_2_Crts_code_update_portfolio_uploader_TFUND_0.4_13072020.xlsx" to variable "CRTSID_INPUT_PROTFOLIO_FILENAME"
    And I assign "002_3_esi_port_group_owned.xml" to variable "PROTFOLIO_GROUP_FILENAME"

  Scenario:TC2: Create TFUND ALTCRTSID context type using uploader

    Given I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${ALTCRTSID_INPUT_PROTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${ALTCRTSID_INPUT_PROTFOLIO_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE  |
      | BUSINESS_FEED |                                       |

    Then I expect workflow is processed in DMP with total record count as "188"

  Scenario:TC3: Update TFUND CRTSID using uploader

    Given I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${CRTSID_INPUT_PROTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${CRTSID_INPUT_PROTFOLIO_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "188"
    And fail record count as "0"

  Scenario:TC4: Create TFUND Portfoligroup-TFB-AG

    Given I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${PROTFOLIO_GROUP_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${PROTFOLIO_GROUP_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP  |
      | BUSINESS_FEED |                             |
