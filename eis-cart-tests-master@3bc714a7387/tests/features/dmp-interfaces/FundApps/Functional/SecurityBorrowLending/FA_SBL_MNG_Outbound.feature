#https://jira.intranet.asia/browse/TOM-5044
#This is outbound file for Security Borrowing and Lending (SBL) coming from MNG

@tom_5044
Feature: 001 | FundApps | Verify Outbound SBL MNG

  This feature file is to test Outbound file of SBL (Security Borrowing and Lending) MNG
  Verifying Portfolios and Instrument data published for Normal and Lend positions

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "600" to variable "workflow.max.polling.time"

  Scenario: Load MNG Position Data

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/MNG_Positions_Outbound/sql/Clear_balh.sql
    """

    Given I assign "MNGSBL-POSN_NORMAL_OUTBOUND.csv" to variable "NORMAL_INPUT_FILENAME"
    And I assign "MNGSBL-POSN_LEND_OUTBOUND.csv" to variable "LEND_INPUT_FILENAME"
    And I assign "MNGSBL-POSN_NORMAL_OUTBOUND_TEMPLATE.csv" to variable "NORMAL_INPUT_TEMPLATENAME"
    And I assign "MNGSBL-POSN_LEND_OUTBOUND_TEMPLATE.csv" to variable "LEND_INPUT_TEMPLATENAME"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "fa" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${NORMAL_INPUT_FILENAME}" using template "${NORMAL_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/MNG_Positions_Outbound/inputfiles"
    And I create input file "${LEND_INPUT_FILENAME}" using template "${LEND_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/MNG_Positions_Outbound/inputfiles"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"


    When I copy files below from local folder "${TESTDATA_PATH}/MNG_Positions_Outbound/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNGSBL-POSN_NORMAL_OUTBOUND.csv |
      | MNGSBL-POSN_LEND_OUTBOUND.csv   |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNGSBL-POSN_NORMAL_OUTBOUND.csv |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_POSITION         |
      | BUSINESS_FEED |                                 |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNGSBL-POSN_LEND_OUTBOUND.csv |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SBL_POSITION   |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Publish File

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_POSITION_SUB |
      | XML_MERGE_LEVEL      | 2                                |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory