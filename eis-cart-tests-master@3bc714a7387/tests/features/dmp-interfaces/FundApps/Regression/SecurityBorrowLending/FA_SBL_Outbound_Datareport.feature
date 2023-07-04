#https://jira.intranet.asia/browse/TOM-5079
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=45.+SBL+Holdings+Report#MainDeck-questions
#This is outbound file for Security Borrowing and Lending (SBL)
#EISDEV-5396 : As part of this ticket prior business date check in mdx has been added. changing feature file to append dynamic date to file name
#EISDEV-6285: FundApps Datareport publishing logic to exclude positions configured for PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSLPRD
#Add BRS position and SBL Load logic
#EISDEV-6383: Adding column for robo positions
#EISDEV-6358: This feature file was failing in regression as the TH0268010Z03 was end dated. this is fixed under jira JIRA-6447.
#The new security set up by LBU does not have all the security master data. Excluding sec master data from recon
#EISDEV-6537: Adding security load files as during regression the positions fail fur to missing security
# Removing the steps related to exclusion  list since it is not valid after TH go Live
#EISDEV-6477: Change for ROBOCOLL


#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@gc_interface_securities @gc_interface_portfolios @gc_interface_positions
@dmp_regression_unittest
#@dmp_regression_integrationtest
@tom_5079 @dmp_fundapps_functional @dmp_fundapps_regression @tom_5170 @tom_5148 @sbl @eisdev_5396 @eisdev_6285 @eisdev_6285_sbl @eisdev_6383 @eisdev_6358
@eisdev_6537 @eisdev_6913 @eisdev_6919 @eisdev_6477

Feature: FundApps | SBL Positions | Outbound feature

  1. MNGSBL - Loading 1 record for a given Fund, Security and Counterparty combination : Should be published as an individual record.
  2. TMBAMSBL - Loading 2 records for a given fund, security and counterparty combination : This should be published as 1 record with positions summed.
  3. CITISBL - Loading 2 records for a given fund, security combination with different counterparties : Should be published as individual records.
#  4. Load 1 records for BRS SBL position and based on PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSLPRD this row should exclude from Publish,

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
    And I assign "BRS_DMP_F211_RestrictedPosition" to variable "INPUT_F211_FILENAME"
    And I assign "BRS_DMP_F211_RestrictedPosition_Template.xml" to variable "INPUT_F211_TEMPLATENAME"


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

  Scenario Outline: Load Security data for BOCI, EIMK and TMBAM

    Given I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/<FILE_NAME>" file with below parameters
      | FILE_PATTERN  | <FILE_NAME>    |
      | MESSAGE_TYPE  | <MESSAGE_TYPE> |
      | BUSINESS_FEED |                |

    Examples:
      | FILE_NAME          | MESSAGE_TYPE             |
      | TMBAMSM.xml        | EIS_MT_BRS_SECURITY_NEW  |
      | BOCIEISLINSTLE.csv | EIS_MT_BOCI_DMP_SECURITY |
      | EIMKEISLINSTLE.csv | EIS_MT_EIMK_DMP_SECURITY |

  Scenario: Load BOCI Position Data

    Given I execute below query to clear balance history
    """
    ${TESTDATA_PATH}/Outbound_SBL_Positions/sql/Clear_balh.sql
    """

    Given I assign "BOCI-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "BOCI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_POSITION |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Load EIMK Position Data

    Given I assign "EIMK-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "EIMK-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_POSITION |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Load TMBAM Position Data

    Given I assign "TBAMPOSITN.xml" to variable "INPUT_FILENAME"
    And I assign "TBAMPOSITIONS_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with success record count as "1"


  Scenario: Load MNG SBL Position Data

    Given I assign "MNGSBL-POSN" to variable "INPUT_FILENAME"
    And I assign "MNGSBL-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SBL_POSITION                |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with success record count as "2"


  Scenario: Load TMBAM SBL Position Data
    Given I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD-Mon-YY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    Given I assign "TMBAMSBL-POSN" to variable "INPUT_FILENAME"
    And I assign "TMBAMSBL-POSN_TEMPLATE.xml" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211   |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with success record count as "2"


  Scenario: Load CITI SBL Position Data

    Given I assign "CITI-POSN" to variable "INPUT_FILENAME"
    And I assign "CITI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles"

    When I process "${TESTDATA_PATH}/Outbound_SBL_Positions/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_CITI_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with success record count as "2"


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

    Given I assign "ROBOSBL-POSN" to variable "INPUT_FILENAME"
    And I assign "ROBOSBL-POSN_TEMPLATE" to variable "INPUT_TEMPLATENAME"
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

    Given I assign "SSDR_SBL_datareport_expected.csv" to variable "MASTER_FILE"

    When I capture current time stamp into variable "recon.timestamp"

    Then I exclude below columns from CSV file while doing reconciliations
      | file:${TESTDATA_PATH}/Outbound_SBL_Positions/outfiles/expected/SSDR_SBL_datareport_excluded_column.txt |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/Outbound_SBL_Positions/outfiles/expected/${MASTER_FILE}                              |
      | File2 | ${TESTDATA_PATH}/Outbound_SBL_Positions/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
