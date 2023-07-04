#https://jira.pruconnect.net/browse/EISDEV-6000
#Requirement: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=Portfolio+Master
#Technical specification : https://collaborate.pruconnect.net/display/EISTOMR4/TH+-+GS+Portfolio+Master+Enhancements

#https://jira.pruconnect.net/browse/EISDEV-6423
#Funtiona specification : https://collaborate.pruconnect.net/display/EISTT/TMB-DMP-NewCash

@gc_interface_portfolios
@dmp_regression_integrationtest
@eisdev_6000 @001_portfolios_thai_port_code @dmp_thailand_portfolios @dmp_thailand @eisdev_6423
Feature: This feature is to test the THAI_PORT_CODE newly added columns using uploader

  Additional attribute required in Golden source portfolio master GUI and portfolio master upload, this field is require for TMBAM or TFUND or TMB portfolio code
  This feature file is to test create or update the THAI_PORT_CODE.

  EISDEV-6423
  Thailand portfolio translation file should generates every day before start of the business, which is use in thailand pass through translation

  Scenario: Initialize variables and Deactivate Existing test accounts to maintain clean state before executing tests
    Given I assign "DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_FILENAME"
    And I assign "DMP_R3_PortfolioMasteringTemplate_Final_4.11_update.xlsx" to variable "INPUT_FILENAME_FOR_UPDATE"
    And I assign "tests/test-data/dmp-interfaces/Thailand/Portfolio/Uploader" to variable "testdata.path"
    And I assign "/dmp/resources/thailand" to variable "PUBLISHING_DIRECTORY"
    And I assign "th_portcode_uat_translation" to variable "PUBLISHING_UAT_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I extract below values for row 2 from EXCEL file "${INPUT_FILENAME}" in local folder "${testdata.path}/infiles" and assign to variables:
      | THAI_PORT_CODE | VAR_THAI_PORT_CODE_INSERT |
    And I extract below values for row 2 from EXCEL file "${INPUT_FILENAME_FOR_UPDATE}" in local folder "${testdata.path}/infiles" and assign to variables:
      | THAI_PORT_CODE | VAR_THAI_PORT_CODE_UPDATE |
    And I execute below query to "deactivate the existing records, so that we can validate the insert and update"
    """
    UPDATE ft_t_acid SET end_tms = sysdate
    WHERE ACCT_ALT_ID in ('${VAR_THAI_PORT_CODE_INSERT}','${VAR_THAI_PORT_CODE_UPDATE}')
    """

  Scenario: Process Portfolio Master template to create new Account and verify its processed successfully

    Given I process "${testdata.path}/infiles/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario:  Verify new Account created with THAI_PORT_CODE in FT_T_ACID table
    Then I expect value of column "THAIID_CREATE_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS THAIID_CREATE_RECORD_COUNT FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '${VAR_THAI_PORT_CODE_INSERT}'
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ACCT_ID_CTXT_TYP = 'THAIID'
    AND DATA_SRC_ID  = 'EIS'
    AND LAST_CHG_USR_ID = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND END_TMS IS NULL
    """

  Scenario: Process Portfolio Master template to update existing Account and verify its processed successfully

    Given I process "${testdata.path}/infiles/${INPUT_FILENAME_FOR_UPDATE}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_FOR_UPDATE}         |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario:  Verify Account is updated with new THAI_PORT_CODE in FT_T_ACID table
    Then I expect value of column "THAIID_UPDATE_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS THAIID_UPDATE_RECORD_COUNT FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '${VAR_THAI_PORT_CODE_UPDATE}'
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ACCT_ID_CTXT_TYP    = 'THAIID'
    AND DATA_SRC_ID         = 'EIS'
    AND LAST_CHG_USR_ID     = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND END_TMS IS NULL
    """

  Scenario: Publish Thailand Portfolio translation file

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_UAT_FILE_NAME}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_UAT_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EITH_DMP_PORTCODE_TRANSLATION_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_UAT_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_UAT_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_UAT_FILE_NAME}*.csv |

  Scenario: Recon Thailand portfolio translation published file contains all the records which were in expected file

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/testdata/001_th_portcode_translation_expected.csv" should exist in file "${testdata.path}/outfiles/actual/${PUBLISHING_UAT_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/actual/001_th_portcode_translation_exceptions_${recon.timestamp}.csv" file
