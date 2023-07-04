#https://collaborate.intranet.asia/display/FUNDAPPS/23.+Outbound+FundApps+Portfolio+File
#Dev :https://jira.intranet.asia/browse/TOM-4249
#QA: https://jira.intranet.asia/browse/TOM-4730
#Enhancement: https://jira.intranet.asia/browse/TOM-4943 :- Removing records that are not with status OPEN as those will no longer be published
#EIDEV-6145: As part of this JIRA. IsAIF flag is set to true for Portfolio E.1. Changing recon template. Also add Address to exclude in reconcile as this is changable datapoint.
#EISDEV-6374: When this feature file is executed on Prod copy in development environment, it works as expected. Some other feature file is end_dating and re-creating the E.1 Entity.
# Adding an Insert in FIGP with ative INST_MENM. Insert is added because this is configuration and not set up from any feed file
#EISDEV-6788: New Field InvestmentManager13F for Fund File added
#EISDEV-7050 : IsAIF Column derive from FAAIF account group participants, If it is exists then TRUE else FALSE
#EISDEV-7295 : Addition of fields
#EISDEV-7300 : FileNumber Fix
#EISDEV-7337 : Logic change for InvestmentManager13FAffiliation
#EISDEV-7449 : Logic change for InvestmentManager13F

@gc_interface_org_chart @gc_interface_portfolios @gc_interface_funds
@dmp_regression_integrationtest @eisdev_7483
@tom_4730 @dmp_fundapps_functional @fund_apps_portfolio_outbound @dmp_fundapps_regression @tom_4943 @eisdev_6145
@eisdev_6374 @eisdev_6788 @eisdev_7050 @eisdev_7295 @eisdev_7330 @eisdev_7337 @eisdev_7449

Feature: Outbound Portfolio file for Fundapps (Golden Source)

  1.Loading fund  files for below LBUs:
  a.MANDG
  b.BOCI
  c.Eastspring Japan
  d.Eastspring Korea
  2.Publishing fundapps outbound portfolio file
  3.Reconciling the outbound portfolio file with reference file

  Scenario Outline: Load pre-requisite ORG Chart Data before file

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Portfolio" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"

    And I process "${testdata.path}/inputfiles/OrgCharts/<ORG_CHART_FILE_NAME>" file with below parameters
      | FILE_PATTERN  | <ORG_CHART_FILE_NAME>  |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL |
      | BUSINESS_FEED |                        |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    Examples:
      | ORG_CHART_FILE_NAME                  |
      | EIMK_ORG_Chart_template_outbound.xls |
      | BOCI_ORG_Chart_template_outbound.xls |
      | ESJP_ORG_Chart_template_outbound.xls |
      | MNG_ORG_Chart_template_outbound.xls  |

  Scenario: Prerequisite - Loading Portfolio Master File

    Given I assign "Portfolio_Master.xlsx" to variable "INPUT_PORTFOLIO_FILENAME"

    And  I process "${testdata.path}/inputfiles/${INPUT_PORTFOLIO_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_PORTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario Outline: Load pre-requisite Fund file with <MESSAGE_TYPE> message type

    Given I process "${testdata.path}/inputfiles/<FILE_NAME>" file with below parameters
      | FILE_PATTERN  | <FILE_NAME>    |
      | MESSAGE_TYPE  | <MESSAGE_TYPE> |
      | BUSINESS_FEED |                |

    Examples:Load pre-requisite Fund file for MNG
      | FILE_NAME                  | MESSAGE_TYPE        |
      | MANGEISLFUNDLE20190607.csv | EIS_MT_MNG_DMP_FUND |

    Examples:Load pre-requisite Fund file for EIMK
      | FILE_NAME                  | MESSAGE_TYPE         |
      | EIMKEISLFUNDLE20190607.csv | EIS_MT_EIMK_DMP_FUND |

    Examples:Load pre-requisite Fund file for ESJP
      | FILE_NAME                  | MESSAGE_TYPE         |
      | ESJPEISLFUNDLE20190607.csv | EIS_MT_ESJP_DMP_FUND |

    Examples:Load pre-requisite Fund file for BOCI
      | FILE_NAME                  | MESSAGE_TYPE         |
      | BOCIEISLFUNDLE20190607.csv | EIS_MT_BOCI_DMP_FUND |

  Scenario: Adding Portfolio E.1 to IsAIF Entity Group.

    Given I execute below query to "Adding Portfolio E.1 to IsAIF Entity Group"
    """
    ${testdata.path}/sql/configuration_aif.sql
    """

  Scenario: Adding Portfolio E35100 to FAAIF Portfolio Group.

    Given I execute below query to "Adding Portfolio E35100 to FAAIF Portfolio Group"
    """
    ${testdata.path}/sql/configuration_aif_acgp.sql
    """

  Scenario: Setup static data for Form13FCIK, Form13FFileNumber, Country,PostalCode & City

    Given I execute below query to "Adding Portfolio E35100 to FAAIF Portfolio Group"
    """
    ${testdata.path}/sql/Setup_static_data.sql
    """

  Scenario: Publish outbound portfolio file

    Given I assign "OUTBOUND_PORTFOLIO" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_FUNDAPPS_FUND_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded for Fundapps Portfolio data

    Given I assign "OUTBOUND_PORTFOLIO_REFERENCE.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    Then I exclude below columns from CSV file while doing reconciliations
      | PortfolioName |
      | Address       |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/reference/${MASTER_FILE} |
      | File2 | ${testdata.path}/outfiles/runtime/${OUTPUT_FILE}   |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
