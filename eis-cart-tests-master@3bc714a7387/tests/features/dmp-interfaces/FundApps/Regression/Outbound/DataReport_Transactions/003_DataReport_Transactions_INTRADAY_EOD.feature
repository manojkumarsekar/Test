#https://jira.intranet.asia/browse/TOM-5219

#EISDEV-6285: FundApps Datareport publishing logic to exclude positions configured for PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD
#Add BRS position Load logic
#Removing the steps related to exclusion  list since it is not valid after TH go Live

@gc_interface_transactions @gc_interface_portfolios
#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@dmp_regression_unittest
#@dmp_regression_integrationtest
@fund_apps @dmp_fundapps_regression @tom_5219 @eisdev_6285 @eisdev_6285_trn @eisdev_6913
Feature: 003 | FundApps | Data Report | Verify Transactions Data Report
  This feature file checks if transactions that are received from EOD BRS files are successfully published
  even after they have been loaded and set up using BRS Intraday

#  As part of EISDEV-6285 Load 1 records for BRS Transaction and based on PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FATXNPRD this row should exclude from Publish.
#  Fund id : 6285_BRS_TRN_LF1


  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/DataReport_Transactions" to variable "TESTDATA_PATH"
    And I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    And I assign "TC03_SSDR_Transaction_Report" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "TC3_001_BRS_EOD_NONLATAM.xml" to variable "INPUTFILE_NAME1"

    # Portfolio Uploader variable
    And I assign "BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"

    And I execute below query and extract values of "CURR_DATE_2" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_2 from dual
     """

    And I execute below query and extract values of "CURR_DATE_3" into same variables
     """
     select TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_3 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM" into same variables
      """
      SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM FROM DUAL
      """

    And I create input file "${INPUTFILE_NAME1}" using template "TC3_001_BRS_EOD_NONLATAM_Template.xml" from location "${TESTDATA_PATH}/inputfiles"

  #Publish Transaction Loaded from Other feature file.
  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}* |

#  Scenario: Create portfolios for BRS Transaction Load
#
#    Given I assign "'6285_BRS_TRN_LF1'" to variable "PROD_PORTFOLIO_EXCLUSION"
#
#    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUT_PROTFOLIO_FILENAME}" file with below parameters
#      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
#      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
#      | BUSINESS_FEED |                                      |
#
#    When I expect workflow is processed in DMP with total record count as "1"
#
#    And I execute below query to Inserting ACGP for exclusion portfolios
#    """
#    ${TESTDATA_PATH}/sql/InsertIntoACGPTable.sql
#    """

  Scenario: Load ADX TRAN File using intraday

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME1}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    When I expect workflow is processed in DMP with total record count as "2"

  Scenario: Load ADX TRAN File using EOD

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |
      | BUSINESS_FEED |                                      |

    When I expect workflow is processed in DMP with total record count as "2"

  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

  Scenario: Verify Published Transactions

    Given I expect value of column "PUB_TRAN_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS PUB_TRAN_COUNT FROM FT_T_PBAT PBAT, FT_T_EXTR EXTR
    WHERE PBAT.SBEX_OID IN
    (
    SELECT SBEX_OID AS RUNTIME_PUB_TMS FROM (SELECT SUBSCRIPTION_NME,START_TMS,SBEX_OID, ROW_NUMBER()
    OVER (PARTITION BY SUBSCRIPTION_NME ORDER BY START_TMS DESC) AS RECORD_ORDER
    FROM FT_V_PUB1
    WHERE PUB_STATUS = 'CLOSED' AND SUBSCRIPTION_NME = 'EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB') WHERE RECORD_ORDER =1
    )
    AND PBAT.PUBLISHED_TBL_ID = 'EXTR'
    AND PBAT.PUB_CROSS_REF_ID = EXTR.EXEC_TRD_ID
    AND EXTR.TRD_ID LIKE '%4698TC1TRN%${TRD_VAR_NUM}'
    """

#  Scenario: Excluded portfolio and datasource should not Published in Transaction DataReport
#
#    Given I assign "TC03_SSDR_Excluded_Transaction_Template.csv" to variable "MASTER_FILE_TRANSACTION_EXCLUDE"
#
#    Then I exclude below columns from CSV file while doing reconciliations
#      | file:${TESTDATA_PATH}/outfiles/TC03_SSDR_Excluded_Transaction_Column.txt |
#
#    Then I expect none of the records from file1 of type CSV exists in file2
#      | File1 | ${TESTDATA_PATH}/outfiles/${MASTER_FILE_TRANSACTION_EXCLUDE}                   |
#      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |