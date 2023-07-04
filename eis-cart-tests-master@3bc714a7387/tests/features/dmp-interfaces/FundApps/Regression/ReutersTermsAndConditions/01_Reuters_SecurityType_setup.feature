#https://jira.pruconnect.net/browse/EISDEV-5383
#EISDEV-6285: FundApps Datareport publishing logic to exclude positions configured for PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD
#Add BRS position and SBL Load logic
#EISDEV-6934:  Include securities related to ROBO COLL
#EISDEV-7109:  Changed query for SBL Pos Date

@gc_interface_reuters @gc_interface_securities @gc_interface_funds @gc_interface_portfolios @gc_interface_positions
@dmp_regression_integrationtest
@dmp_fundapps_regression @eisdev_5383 @eisdev_6285 @eisdev_6285_sectype_datareport @eisdev_6934
@eisdev_7109

Feature: Test the setup of Reuters Security type and compare with RDM Security type in data report.

  Testing the setup of reuters security type as per logic defined in JIRA.
  For the corresponding reuters security type, we are comparing it with RDM Security type and publishing a data report
  for mismatch.

  As part of EISDEV-6285 Load 1 records for BRS position and based on PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD this row should exclude from Publish.
  Fund id : 6285_BRS_POS_LF1 and security ISIN :US718286CB15

  Scenario: Assign variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/ReutersTermsConditionsSecurity/RTSecTypeinfiles/infiles" to variable "testdata.path"
    And I assign "01_RTTest.csv" to variable "RT_INPUT_FILENAME"
    And I assign "01_TBAMEISLINSTMT.csv" to variable "SEC_INPUT_FILENAME"
    And I assign "01_TBAMEISLPOSITN_Template.csv" to variable "POS_INPUT_TEMPLATE"
    And I assign "01_TBAMEISLPOSITN.csv" to variable "POS_INPUT_FILENAME"
    And I assign "01_TBAMEISLFUND.csv" to variable "FUND_INPUT_FILENAME"
    And I generate value with date format "dd/MM/YYYY" and assign to variable "CURR_DATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I create input file "${POS_INPUT_FILENAME}" using template "${POS_INPUT_TEMPLATE}" from location "${testdata.path}"

    # Portfolio Uploader variable
    And I assign "BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"

    # File 14 Variable
    And I assign "BRS_DMP_F14_Position" to variable "INPUT_F14_FILENAME"
    And I assign "BRS_DMP_F14_Position_Template.xml" to variable "INPUT_F14_TEMPLATENAME"

    And I execute below query and extract values of "DYNAMIC_DATE_BRS" into same variables
     """
     select to_char(max(GREG_DTE),'MM/dd/YYYY') as DYNAMIC_DATE_BRS from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query and extract values of "DYNAMIC_DATE_SBL" into same variables
     """
     select to_char(GREG_DTE,'DD Mon YYYY') as DYNAMIC_DATE_SBL from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """

    And I execute below query to clear the balance history
     """
     ${testdata.path}/sql/Clear_balh.sql
     """

    #End-dating to resolve split instruments issue
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TSTRTS0'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'XS20TSTRTS19'"

  Scenario: TC_1: Load the TMBAM file to set up the instruments required with RDMSCTYP
    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SEC_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with success record count as "116"

  Scenario: TC_2: Load pre-requisite Fund Data before file

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${FUND_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${FUND_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_FUND   |
      | BUSINESS_FEED |                        |
    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_3: Load the report files to return the securities required for the publish report
    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${POS_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${POS_INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_POSITION |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with success record count as "116"

  Scenario: Prerequisite - Inserting ACGP for exclusion portfolios

    Given I assign "'6285_BRS_POS_LF1'" to variable "PROD_PORTFOLIO_EXCLUSION"

    And I execute below query to create paticipants for FAPRDEXCLPORT
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

  Scenario: Create portfolios for BRS Position Load

    Given I process "${testdata.path}/testdata/${INPUT_PROTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    When I expect workflow is processed in DMP with total record count as "1"

  Scenario: Load BRS Position Data(File 14) for Datareport Testing

    Given I create input file "${INPUT_F14_FILENAME}_${VAR_SYSDATE}.xml" using template "${INPUT_F14_TEMPLATENAME}" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${INPUT_F14_FILENAME}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_F14_FILENAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM        |
      | BUSINESS_FEED |                                          |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Prerequisite - End dating Instruments to reload the same set of records and to delete positions
  This scenario set END_TMS as SYSDATE in FT_T_ISID table for all TBAM instruments

    Given I extract below values for row 2 from CSV file "ROBOSBL-POSN_COLL_TEMPLATE.csv" in local folder "${testdata.path}/template" with reference to "Date" column and assign to variables:
      | ISIN  | RCR_ISIN  |
      | SEDOL | RCR_SEDOL |

    Then I inactivate "${RCR_ISIN},${RCR_SEDOL}" instruments in GC database

  Scenario: Load Positions data for ROBO Collateral
    Given I create input file "ROBOSBL-POSN_COLL.csv" using template "ROBOSBL-POSN_COLL_TEMPLATE.csv" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/ROBOSBL-POSN_COLL.csv" file with below parameters
      | FILE_PATTERN  | ROBOSBL-POSN_COLL.csv        |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION |
      | BUSINESS_FEED |                              |

  Scenario: Load the reuters terms and conditions security file with test instruments with RTSCTYP
    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RT_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${RT_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |
    Then I expect workflow is processed in DMP with success record count as "116"

  Scenario: Check if published file contains all the records which were loaded and compare all the incorrect sec types

    Given I assign "SSDR_SecType" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    And I assign "SecType_Report_expected" to variable "MASTER_FILE"

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_SECTYPE_DATAREPORT |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Compare sec type file against expected output

    Given I exclude below column indices from CSV file while doing reconciliations
      | 1 |
      | 8 |

    And I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/SSDR_SecType_include_template.csv                    |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Excluded portfolio should not Published in SecType DataReport

    Given I assign "SSDR_SecType_exclude_template.csv" to variable "MASTER_FILE_EXCLUDE"

    Then I expect none of the records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/${MASTER_FILE_EXCLUDE}                               |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
