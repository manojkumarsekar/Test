#https://jira.intranet.asia/browse/TOM-4542
#Position Data report required for SSDR team
#Confluence: https://collaborate.intranet.asia/display/TOMR4/Position+Report
#EISDEV-6285: FundApps Datareport publishing logic to exclude positions configured for PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD
#Add BRS position Load logic
#EISDEV-6414: Verify Position publishing for Security type EFUT for Data Report and PPM Position Report
#Removing the steps related to exclusion  list since it is not valid after TH go Live


@gc_interface_securities @gc_interface_portfolios @gc_interface_reuters @gc_interface_portfolios @eisdev_6913
#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@dmp_regression_unittest
#@dmp_regression_integrationtest
@tom_4542 @postn_datareports @tom_5000 @tom_5052 @dmp_fundapps_functional @dmp_fundapps_regression @esidev_5382 @eisdev_6285 @eisdev_6285_pos @eisdev_6414
Feature: 001 | FundApps | Data Report | Verify Positions Data Report

  The feature file is a basic file to check if the position data report is getting generated for SSDR team
  TOM-5052: Checking if GICS data is getting published. As the data can change with respect to instrument, not regression tags.

#  As part of EISDEV-6285 Load 1 records for BRS position and based on PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD this row should exclude from Publish.
#  Fund id : 6285_BRS_POS_LF1 and security cusip :S69108249

  Scenario: Assign Variables and pre-requisites

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/DataReports_Positions" to variable "testdata.path"
    And I assign " /dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    And I assign "SSDR_Positions_Report" to variable "PUBLISHING_FILE_NAME"
    And I assign "SSDR_POS_Summary_Report" to variable "PUBLISHING_SUMMARY_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I assign "${PUBLISHING_FILE_NAME}*_1.csv" to variable "PUBLISHING_FILE_FULL_NAME"
    And I assign "${PUBLISHING_SUMMARY_FILE_NAME}*_1.csv" to variable "PUBLISHING_SUMMARY_FILE_FULL_NAME"
    And I assign "RTISSR-TNC-SECURITY.csv" to variable "ISSUER_INPUT_FILENAME"

#    # Portfolio Uploader variable
#    And I assign "BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"
#
#    # File 14 Variable
#    And I assign "BRS_DMP_F14_Position.xml" to variable "INPUT_F14_FILENAME"
#    And I assign "BRS_DMP_F14_Position_Template.xml" to variable "INPUT_F14_TEMPLATENAME"

    And I execute below query and extract values of "DYNAMIC_DATE_BRS" into same variables
     """
     select to_char(max(GREG_DTE),'MM/dd/YYYY') as DYNAMIC_DATE_BRS from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query to clear the Balance history
    """
    ${testdata.path}/sql/Clear_balh.sql
    """

  Scenario: Create Position file with Position Date as SYSDATE-1 and Load into DMP

    Given I assign "ESGA-POSITION.csv" to variable "INPUT_FILENAME"
    And I assign "ESGA-POSITION_Template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"
    And I assign "ESGAEISLINSTMT.csv" to variable "INPUT_FILENAME_SEC"

  Scenario: Load security file

    Given I inactivate "FR0000120644" instruments in GC database

    Given  I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_SEC} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME_SEC}    |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_SECURITY |

  Scenario: Load position file

    Given  I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ESGA-POSITION.csv        |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_POSITION |

  Scenario: Create Position file with Position Date as SYSDATE and Load into DMP

    Given I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I assign "ESGA-POSITION.csv" to variable "INPUT_FILENAME"
    And I assign "ESGA-POSITION_Template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

  Scenario: Load position file

    Given  I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ESGA-POSITION.csv        |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_POSITION |

  Scenario: Load the reuters terms and conditions security file with test instruments to create the issuer so that we can validate summary report

    When I process "${testdata.path}/inputfiles/template/${ISSUER_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${ISSUER_INPUT_FILENAME}      |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I expect workflow is processed in DMP with total record count as "1"

#  Scenario: Create portfolios for BRS Position Load
#
#    Given I assign "'6285_BRS_POS_LF1'" to variable "PROD_PORTFOLIO_EXCLUSION"
#
#    When I process "${testdata.path}/inputfiles/testdata/${INPUT_PROTFOLIO_FILENAME}" file with below parameters
#      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
#      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
#      | BUSINESS_FEED |                                      |
#
#    Then I expect workflow is processed in DMP with total record count as "1"
#
#    Then I execute below query to create paticipants for FAPRDEXCLPORT
#    """
#    ${testdata.path}/sql/InsertIntoACGPTable.sql
#    """
#
#  Scenario: Load BRS Position Data(File 14) for Datareport Testing
#
#    Given I create input file "${INPUT_F14_FILENAME}_${VAR_SYSDATE}.xml" using template "${INPUT_F14_TEMPLATENAME}" from location "${testdata.path}/inputfiles"
#
#    When I process "${testdata.path}/inputfiles/testdata/${INPUT_F14_FILENAME}_${VAR_SYSDATE}.xml" file with below parameters
#      | FILE_PATTERN  | ${INPUT_F14_FILENAME}_${VAR_SYSDATE}.xml |
#      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM        |
#      | BUSINESS_FEED |                                          |
#
#    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Triggering Publishing for Position DataReport Details

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv             |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_POSITION_DATAREPORTS_SUB |
      | COLUMN_SEPARATOR     | ,                                       |
      | COLUMN_TO_SORT       | 3                                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_FULL_NAME} |

  Scenario: Reconciling files for Position DataReport Details

    Given I assign "SSDR_Positions_Report_template.csv" to variable "MASTER_FILE"

    When I capture current time stamp into variable "recon.timestamp"

    Then I exclude below columns from CSV file while doing reconciliations
      | file:${testdata.path}/outfiles/SSDR_Position_Detail_Report_Exclude_columns.txt |

    Then I expect each record in file "${testdata.path}/outfiles/${MASTER_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

#  Scenario: Excluded portfolio and datasource should not Published in Position detail DataReport
#
#    Given I assign "SSDR_Exclude_Positions_Report_template.csv" to variable "MASTER_FILE_EXCLUDE"
#
#    Then I exclude below columns from CSV file while doing reconciliations
#      | file:${testdata.path}/outfiles/SSDR_Position_Detail_Report_Exclude_columns.txt |
#
#    Then I expect none of the records from file1 of type CSV exists in file2
#      | File1 | ${testdata.path}/outfiles/${MASTER_FILE_EXCLUDE}                               |
#      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Triggering Publishing for Position DataReport Summary

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_SUMMARY_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_SUMMARY_FILE_NAME}.csv    |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_POSNSUMMARY_REPORTS_SUB |
      | COLUMN_SEPARATOR     | ,                                      |
      | COLUMN_TO_SORT       | 3                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_SUMMARY_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_SUMMARY_FILE_FULL_NAME} |

  Scenario: EFUT is Published in Position summary DataReport

    Given I assign "SSDR_POS_Summary_Report_Template.csv" to variable "MASTER_FILE_SUMMARY"

    When I capture current time stamp into variable "recon.timestamp"

    Then I exclude below columns from CSV file while doing reconciliations
      | file:${testdata.path}/outfiles/SSDR_Position_Summary_Report_Exclude_columns.txt |

    Then I expect each record in file "${testdata.path}/outfiles/${MASTER_FILE_SUMMARY}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_SUMMARY_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/SSDR_Exclude_POS_Summary_Report_exceptions_${recon.timestamp}.csv" file

#  Scenario: Excluded portfolio and datasource should not Published in Position summary DataReport
#
#    Given I assign "SSDR_Exclude_POS_Summary_Report_Template.csv" to variable "MASTER_FILE_SUMMARY_EXCLUDE"
#
#    Then I exclude below columns from CSV file while doing reconciliations
#      | file:${testdata.path}/outfiles/SSDR_Position_Summary_Report_Exclude_columns.txt |
#
#    Then I expect none of the records from file1 of type CSV exists in file2
#      | File1 | ${testdata.path}/outfiles/${MASTER_FILE_SUMMARY_EXCLUDE}                               |
#      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_SUMMARY_FILE_NAME}_${VAR_SYSDATE}_1.csv |