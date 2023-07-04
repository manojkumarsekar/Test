#https://jira.intranet.asia/browse/EISDEV-6383
#Zero positions loaded to indicate that all lend positions have been sold off
#EISDEV-6536: Adding step to load security first
#EISDEV-6537: Adding security load files as during regression the positions fail fur to missing security
#EISDEV-6919 - Removing the Exclusion list related steps since it is not valid after TH Go Live
#EISDEV-6477: Change for ROBOCOLL

#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@gc_interface_securities @gc_interface_portfolios @gc_interface_positions
@dmp_regression_unittest
#@dmp_regression_integrationtest
@dmp_fundapps_functional @dmp_fundapps_regression @eisdev_6383 @eisdev_6537 @sbl @eisdev_6919 @eisdev_6477
Feature: FundApps | SBL Positions | Outbound feature | Zero lend Positions

  Lend positions with one 0 quantity position will be loaded for each LBU to represent that
  all positions of the LBU have been sold off. The resulting datareport for SBL should have
  no rows returned except header.

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending" to variable "TESTDATA_PATH"

    # Portfolio Uploader variable
    And I assign "BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"

    # Portfolio File54 variable
    And I assign "BRS_DMP_F54_esi_portfolio.xml" to variable "INPUT_F54_FILENAME"
    And I assign "BRS_DMP_F54_esi_portfolio_Template.xml" to variable "INPUT_F54_TEMPLATENAME"

    # Portfolio group variable
    And I assign "BRS_DMP_esi_port_group.xml" to variable "INPUT_PROTGROUP_FILENAME"
    And I assign "BRS_DMP_esi_port_group_Template.xml" to variable "INPUT_PORTGROUP_TEMPLATENAME"

    # File 14 Variable
    And I assign "BRS_DMP_F14_Position.xml" to variable "INPUT_F14_FILENAME"
    And I assign "BRS_DMP_F14_Position_Template.xml" to variable "INPUT_F14_TEMPLATENAME"

    # File 211 Variable
    And I assign "BRS_DMP_F211_RestrictedPosition_0Position" to variable "INPUT_F211_FILENAME"
    And I assign "BRS_DMP_F211_RestrictedPosition_0Position_Template.xml" to variable "INPUT_F211_TEMPLATENAME"


    And I execute below query and extract values of "DYNAMIC_FILE_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'YYYYMMDD') as DYNAMIC_FILE_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query and extract values of "DYNAMIC_DATE_BRS" into same variables
     """
     select to_char(max(GREG_DTE),'MM/dd/YYYY') as DYNAMIC_DATE_BRS from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query and extract values of "DYNAMIC_DATE_POS" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE_POS from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """
    And I execute below query and extract values of "DYNAMIC_DATE_SBL" into same variables
     """
     select to_char(max(GREG_DTE),'DD Mon YYYY') as DYNAMIC_DATE_SBL from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """

  Scenario: Load Portfolio Template for Custodian setup

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/CITI_SBL.xlsx" file with below parameters
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | CITI_SBL.xlsx                        |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Load Security data for BOCI, EIMK and TMBAM

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/TBAMEISLINSTLE.csv" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | TMBAMSM.xml             |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    And I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/BOCIEISLINSTLE.csv" file with below parameters
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | BOCIEISLINSTLE.csv       |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |

    And I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/EIMKEISLINSTLE.csv" file with below parameters
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | EIMKEISLINSTLE.csv       |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_SECURITY |

  Scenario: Load BOCI Position Data

    Given I execute below query to clear balance history
    """
    ${TESTDATA_PATH}/Outbound_SBL_Positions/sql/Clear_balh.sql
    """

    Given I assign "BOCI-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "BOCI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_POSITION |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Load EIMK Position Data

    Given I assign "EIMK-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "EIMK-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_POSITION |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Load TMBAM Position Data

    Given I assign "TBAMEISLPOSITN.xml" to variable "INPUT_FILENAME"
    And I assign "TBAMPOSITIONS_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Load MNG SBL Position Data

    Given I assign "MNGSBL-POSN_0Position" to variable "INPUT_FILENAME"
    And I assign "MNGSBL-POSN_0Position_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SBL_POSITION                |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Load TMBAM SBL Position Data
    Given I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD-Mon-YY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    Given I assign "TMBAMSBL-POSN_0Position" to variable "INPUT_FILENAME"
    And I assign "TMBAMSBL-POSN_0Position_TEMPLATE.xml" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211   |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Load CITI SBL Position Data

    Given I assign "CITI-POSN_0Position" to variable "INPUT_FILENAME"
    And I assign "CITI-POSN_0Position_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_CITI_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with total record count as "1"

#
#  Scenario: Prerequisite - Inserting ACGP for exclusion portfolios
#
#    Given I assign "'6285_BRS_LF1'" to variable "PROD_PORTFOLIO_EXCLUSION"
#
#    And I execute below query to create paticipants for FAPRDEXCLPORT
#    """
#    ${TESTDATA_PATH}/Outbound_SBL_Positions/sql/InsertIntoACGPTable.sql
#    """
#
#  Scenario: Create portfolios for BRS SBL Load
#
#    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_PROTFOLIO_FILENAME}" file with below parameters
#      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
#      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
#      | BUSINESS_FEED |                                      |
#
#    When I expect workflow is processed in DMP with total record count as "1"
#
#  Scenario: Creates BRSFundID as Context type using File54 for BRS SBL Load
#
#    Given I create input file "${INPUT_F54_FILENAME}" using template "${INPUT_F54_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"
#
#    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_F54_FILENAME}" file with below parameters
#      | BUSINESS_FEED |                       |
#      | FILE_PATTERN  | ${INPUT_F54_FILENAME} |
#      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |
#
#    Then I expect workflow is processed in DMP with total record count as "1"
#
#  Scenario: Load portfolio group file from BRS to DMP for create TBMAM group and participants to BRS SBL Load
#
#    Given I create input file "${INPUT_PROTGROUP_FILENAME}" using template "${INPUT_PORTGROUP_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"
#
#    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_PROTGROUP_FILENAME}" file with below parameters
#      | BUSINESS_FEED |                             |
#      | FILE_PATTERN  | ${INPUT_PROTGROUP_FILENAME} |
#      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP  |
#
#    Then I expect workflow is processed in DMP with total record count as "1"
#
#  Scenario: Load BRS TMBAM Position Data(File 14) for SBL Testing
#
#    Given I create input file "${INPUT_F14_FILENAME}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_F14_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"
#
#    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_F14_FILENAME}_${DYNAMIC_FILE_DATE}.xml" file with below parameters
#      | FILE_PATTERN  | ${INPUT_F14_FILENAME}_${DYNAMIC_FILE_DATE}.xml |
#      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM              |
#      | BUSINESS_FEED |                                                |
#
#    Then I expect workflow is processed in DMP with total record count as "1"
#
#  Scenario: Load TMBAM SBL Position Data(File 211) from BRS
#
#    Given I create input file "${INPUT_F211_FILENAME}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_F211_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"
#
#    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_F211_FILENAME}_${DYNAMIC_FILE_DATE}.xml" file with below parameters
#      | FILE_PATTERN  | ${INPUT_F211_FILENAME}_${DYNAMIC_FILE_DATE}.xml |
#      | MESSAGE_TYPE  | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211        |
#      | BUSINESS_FEED |                                                 |
#
#    Then I expect workflow is processed in DMP with total record count as "1"
#
  Scenario: Load Portfolio Custodians for ROBO
    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx" file with below parameters
      | FILE_PATTERN  | DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE        |
      | BUSINESS_FEED |                                             |

  Scenario: Load ROBO Position Data

    Given I assign "ROBOEISLPOSITN.csv" to variable "INPUT_FILENAME"
    And I assign "ROBOEISLPOSITN_Template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_POSITION |
      | BUSINESS_FEED |                          |

  Scenario: Load ROBO SBL Position Data

    Given I assign "ROBOSBL-POSN_0Position" to variable "INPUT_FILENAME"
    And I assign "ROBOSBL-POSN_0Position_TEMPLATE" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}.csv" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"
    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |
    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Publish File

    #Extract Data
    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "SSDR_SBL_datareport" to variable "PUBLISHING_FILE_NAME"
    And I assign " /dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_SBLPOSN_DATAREPORT_SUB |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 7                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/Outbound_SBL_Positions/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Reconciling template file with out file generated

    Given I assign "SSDR_SBL_datareport_0Position_expected.csv" to variable "MASTER_FILE"

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${TESTDATA_PATH}/Outbound_SBL_Positions/outfiles/expected/${MASTER_FILE}                              |
      | ExpectedFile | ${TESTDATA_PATH}/Outbound_SBL_Positions/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |