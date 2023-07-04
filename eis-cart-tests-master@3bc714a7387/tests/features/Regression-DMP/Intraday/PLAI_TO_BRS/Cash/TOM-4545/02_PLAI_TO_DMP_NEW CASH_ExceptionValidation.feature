#Ticket link : https://jira.intranet.asia/browse/TOM-4545
#Parent Ticket: https://jira.intranet.asia/browse/TOM-3393
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844973#Test-logicalMapping
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - Removing scenarios for exception validations with Zero or Blank Amount

@gc_interface_cash
@dmp_regression_unittest
@02_tom_4545_plai_dmp_new_cash @eisdev_7170
Feature: PLAI to DMP NewCash1 feed - Exception Validation

  Description: Validate that system throw exception and should not process the records when:
    a) EXTERN_NEWCASH_ID1 is NULL
    b) AMOUNT is NULL
    c) AMOUNT is 0
    d) CURRENCY is NULL
    e) CASH_TYPE is NULL
    f) SETTLE_DATE is NULL
    g) TRADE DATE is NULL
    h) PORTFOLIO is NULL
    i) PORTFOLIO_NAME is not available in DMP

  Scenario: Load NewCash File

    Given I assign "tests/test-data/Regression-DMP/Intraday/PLAI_TO_BRS/Cash/TOM-4545" to variable "testdata.path"
    And I assign "PLA_FUNDALLOC_ExceptionValidation.csv" to variable "INPUT_FILENAME"
    And I assign "PLA_FUNDALLOC_Template_Exception.csv" to variable "INPUTFILE_TEMPLATE"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILENAME}" using template "${INPUTFILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | EXTERN_NEWCASH_ID1 | ${TIMESTAMP}1 |
      | EXTERN_NEWCASH_ID2 | ${TIMESTAMP}2 |
      | EXTERN_NEWCASH_ID3 | ${TIMESTAMP}3 |
      | EXTERN_NEWCASH_ID4 | ${TIMESTAMP}4 |
      | EXTERN_NEWCASH_ID5 | ${TIMESTAMP}5 |
      | EXTERN_NEWCASH_ID6 | ${TIMESTAMP}6 |
      | EXTERN_NEWCASH_ID7 | ${TIMESTAMP}7 |
      | EXTERN_NEWCASH_ID8 | ${TIMESTAMP}8 |
      | EXTERN_NEWCASH_ID9 | ${TIMESTAMP}9 |


    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}                          |
      | MESSAGE_TYPE  | ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all the records are not processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "0":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario:  Validate that system throw exception and should not process the records when EXTERN_NEWCASH_ID1 is NULL

    Then I expect value of column "EXTERN_NEWCASH_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXTERN_NEWCASH_ID FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.MAIN_ENTITY_ID IS NULL
    AND NTEL.SOURCE_ID = 'TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID = 60001
    AND NTEL.MSG_SEVERITY_CDE = '40'
    AND NTEL.PART_ID = 'TRANS'
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . Cannot process the record as required fields EXTERN NEWCASH ID1 is not present in the input record.%')
    """

  Scenario Outline:  Validate that system throw exception and should not process the records when <ScenarioDescription>

    Given I extract below values for row <Row> from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "EXTERN_NEWCASH_ID1" column and assign to variables:
      | EXTERN_NEWCASH_ID1 | VAR_EXTERN_NEWCASH_ID |

    Then I expect value of column "EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID = 'TRANSLATION'
    AND NTEL.MAIN_ENTITY_ID = '${VAR_EXTERN_NEWCASH_ID}'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID = 60001
    AND NTEL.MSG_SEVERITY_CDE = '40'
    AND NTEL.PART_ID = 'TRANS'
    AND NTEL.PARM_VAL_TXT LIKE ('<Text>%')
    """

    Examples:
      | Row | ScenarioDescription | Text                                                                                                                       |
      | 5   | CURRENCY is NULL    | User defined Error thrown! . Cannot process the record as required fields, CURRENCY is not present in the input record.    |
      | 6   | CASH_TYPE is NULL   | User defined Error thrown! . Cannot process the record as required fields, CASH TYPE is not present in the input record.   |
      | 7   | SETTLE_DATE is NULL | User defined Error thrown! . Cannot process the record as required fields, SETTLE DATE is not present in the input record. |
      | 8   | TRADE DATE is NULL  | User defined Error thrown! . Cannot process the record as required fields, TRADE DATE is not present in the input record.  |
      | 9   | PORTFOLIO is NULL   | User defined Error thrown! . Cannot process the record as required fields, PORTFOLIO is not present in the input record.   |

  Scenario: Validate that system throw exception and should not process the records when PORTFOLIO_NAME is not null but not available in DMP

    Given I extract below values for row 10 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "EXTERN_NEWCASH_ID1" column and assign to variables:
      | EXTERN_NEWCASH_ID1 | VAR_EXTERN_NEWCASH_ID |
      | PORTFOLIO          | VAR_PORTFOLIO         |

    Then I expect value of column "PORTFOLIO" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS PORTFOLIO FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    WHERE TRID.JOB_ID = '${JOB_ID}'
    AND NTEL.MAIN_ENTITY_ID = '${VAR_EXTERN_NEWCASH_ID}'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID = '26'
    AND NTEL.MSG_SEVERITY_CDE = '50'
    AND NTEL.PART_ID = 'NESTED'
    AND NTEL.PARM_VAL_TXT LIKE ('CRTSID ${VAR_PORTFOLIO} ESII AccountAlternateIdentifier')
    """