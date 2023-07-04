# TOM-4557
# SCB_NEW_CASH : SCB to DMP New Cash Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-3392
# Current Ticket : https://jira.intranet.asia/browse/TOM-4557
# Requirement Link : https://collaborate.intranet.asia/display/TOMID/INDONESIA+Consolidated+Requirements
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - Removing scenarios for exception validations with Zero or Blank Amount

@gc_interface_cash
@dmp_regression_unittest
@02_tom_4557_scb_dmp_new_cash @eisdev_7170
Feature: SCB NEW CASH-1: New Cash Interface Testing (SCB to DMP) - Exception

  Below Scenarios are handled as part of this feature:
  1. Validate that system throw exception and should not process the the records when:
    a)EXTERN_NEWCASH_ID1 is NULL
    b)AMOUNT is NULL
    c)AMOUNT is 0
    d)CURRENCY is NULL
    e)CASH_TYPE is NULL
    f)SETTLE_DATE is NULL
    g)TRADE DATE is NULL
  2. Validate that system throw exception and should not process the records when PORTFOLIO_NAME is not null but not available in DMP

  Scenario: Load New Cash file from SCB to DMP

    Given I assign "tests/test-data/Regression-DMP/Intraday/SCB_TO_BRS/Cash/NewCash/TOM-4557" to variable "testdata.path"
    And I assign "subs_redm_report_exception_data.csv" to variable "INPUT_FILE_NAME"
    And I assign "subs_redm_report_exception_template.csv" to variable "INPUT_FILE_TEMPLATE"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    #Dynamically fetching the portfolio name belongs to SCB from DB
    And I execute below query and extract values of "VALID_PORTFOLIO_NAME" into same variables
    """
    SELECT * FROM (SELECT ACCT_ALT_ID as VALID_PORTFOLIO_NAME FROM FT_T_ACID WHERE ACCT_ID_CTXT_TYP in ('ESPORTCDE','ALTCRTSID','CRTSID') AND ACCT_ALT_ID in ('NDANEF','NDCRMF','NDSFIA','NDVDEF','NDHGFF','NDYDFF','NDEIFF','NDSIEF','NDSKMF') AND END_TMS IS NULL) WHERE rownum <= 1
    """

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | EXTERN_NEWCASH_ID1     | ${TIMESTAMP}0 |
      | EXTERN_NEWCASH_ID2     | ${TIMESTAMP}1 |
      | EXTERN_NEWCASH_ID3     | ${TIMESTAMP}2 |
      | EXTERN_NEWCASH_ID4     | ${TIMESTAMP}3 |
      | EXTERN_NEWCASH_ID5     | ${TIMESTAMP}4 |
      | EXTERN_NEWCASH_ID6     | ${TIMESTAMP}5 |
      | EXTERN_NEWCASH_ID7     | ${TIMESTAMP}6 |
      | EXTERN_NEWCASH_ID8     | ${TIMESTAMP}7 |
      | NULL_EXTERN_NEWCASH_ID |               |
      | NULL_PORTFOLIO_NAME    |               |
      | INVALID_PORTFOLIO_NAME | NONEXIST00    |
      | NULL_AMOUNT            |               |
      | ZERO_AMOUNT            | 0             |
      | NULL_CURRENCY          |               |
      | NULL_CASH_TYPE         |               |
      | NULL_SETTLE_DATE       |               |
      | NULL_TRADE_DATE        |               |


    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                           |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                        |
      | MESSAGE_TYPE  | ESII_MT_TAC_SCB_INTRADAY_CASH_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # verifying that file load job is not successful for record having portfolio name not available in DMP
    Then I expect value of column "FAILED_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_FAILED_CNT AS FAILED_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

    # verifying that file load job is not successful when mandatory columns are NULL
    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "6":
    """
    SELECT TASK_PARTIAL_CNT as PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  Scenario: Validating the exception in case of PORTFOLIO_NAME is not available in DMP

    Then I extract below values for row 10 from CSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to '"EXTERN_NEWCASH_ID1"' column and assign to variables:
      | "EXTERN_NEWCASH_ID1" | VAR_EXTERN_NEWCASH_ID |

    # verifying Invalid_portfolio does not exist in DMP
    Given  I expect value of column "PORTFOLIO_COUNT_CHECK" in the below SQL query equals to "0":
    """
    SELECT COUNT(DISTINCT 1) AS PORTFOLIO_COUNT_CHECK
    FROM FT_T_ACID ACID
    INNER JOIN FT_T_EXTR EXTR
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    WHERE ACID.ACCT_ALT_ID = '${INVALID_PORTFOLIO_NAME}'
    AND ETID.EXEC_TRN_ID = '${VAR_EXTERN_NEWCASH_ID}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'ESIITRNID'
    AND ACID.ACCT_ID_CTXT_TYP in ('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 50
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = '${VAR_EXTERN_NEWCASH_ID}'
    AND NTEL.PARM_VAL_TXT LIKE '%${INVALID_PORTFOLIO_NAME}%'
    """

  Scenario: Validating the exception in case of EXTERN_NEWCASH_ID1 is NULL

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID is NULL
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields EXTERN NEWCASH ID1 is not present in the input record.%'
    """

  Scenario Outline: Validate that system throw exception and should not process the records when "<Description>"

    Then I extract below values for row <Row> from CSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to '"EXTERN_NEWCASH_ID1"' column and assign to variables:
      | "EXTERN_NEWCASH_ID1" | VAR_EXTERN_NEWCASH_ID |

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = '${VAR_EXTERN_NEWCASH_ID}'
    AND NTEL.CHAR_VAL_TXT LIKE '%<Error_Message>%'
    """

    Examples:
      | Row | Description         | Error_Message                                                                                                                                       |
      | 3   | PORTFOLIO is NULL   | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields, PORTFOLIO is not present in the input record.   |
      | 6   | CURRENCY is NULL    | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields, CURRENCY is not present in the input record.    |
      | 7   | CASH_TYPE is NULL   | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields, CASH TYPE is not present in the input record.   |
      | 8   | SETTLE DATE is NULL | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields, SETTLE DATE is not present in the input record. |
      | 9   | TRADE DATE is NULL  | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields, TRADE DATE is not present in the input record.  |
