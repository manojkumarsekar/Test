# TOM-4505
# File96-1-2 : BRS to DMP file96 Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-3437
# Current Ticket : https://jira.intranet.asia/browse/TOM-4505
# Requirement Link : https://collaborate.intranet.asia/display/TOM/Intraday+Flows%3A+Cash+Allocations

@gc_interface_cash
@dmp_regression_unittest
@02_tom_4505_brs_dmp_f96
Feature: File96-1: File96-1 File96 Interface Testing (BRS to DMP) - Exception

  Below Scenarios are handled as part of this feature:
  1. Validate that system throw exception and should not process the the records when:
    a)PORTFOLIO_NAME is NULL
    b)AMOUNT is NULL
    c)CASH_TYPE is NULL
    d)TRADE_DATE is NULL
    e)SETTLE_DATE is NULL
  2. Validate that system throw exception and should not process the records when PORTFOLIO_NAME is not null but not available in DMP

  Scenario: Load file 96 from BRS to DMP

    Given I assign "tests/test-data/Regression-DMP/Intraday/BRS_TO_BNP/Cash/File96/TOM-4505" to variable "testdata.path"
    And I assign "esi_newcash_exceptions_data.xml" to variable "INPUT_FILE_NAME"
    And I assign "esi_newcash_exception_template.xml" to variable "INPUT_FILE_EXCEPTION_TEMPLATE"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    #Dynamically fetching the portfolio name from DB
    And I execute below query and extract values of "VALID_PORTFOLIO" into same variables
    """
    SELECT * from (SELECT ACCT_ALT_ID as VALID_PORTFOLIO FROM FT_T_ACID order by 1 desc ) WHERE rownum <= 1
    """

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_EXCEPTION_TEMPLATE}" with below codes from location "${testdata.path}"
      | NULL_PORTFOLIO    |                |
      | NULL_AMOUNT       |                |
      | NULL_CASH_TYPE    |                |
      | NULL_TRADE_DATE   |                |
      | NULL_SETTLE_DATE  |                |
      | INVALID_PORTFOLIO | NONEXIST00     |
      | NEW_CASH_ID1      | ${TIMESTAMP}11 |
      | NEW_CASH_ID2      | ${TIMESTAMP}12 |
      | NEW_CASH_ID3      | ${TIMESTAMP}13 |
      | NEW_CASH_ID4      | ${TIMESTAMP}14 |
      | NEW_CASH_ID5      | ${TIMESTAMP}15 |
      | NEW_CASH_ID6      | ${TIMESTAMP}16 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # verifying that file load job is not successful for record having portfolio name not available in DMP
    Then I expect value of column "FAILED_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_FAILED_CNT AS FAILED_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

    # verifying that file load job is not successful when mandatory columns are NULL
    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "5":
    """
    SELECT TASK_PARTIAL_CNT as PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  Scenario: Validating the exception in case of PORTFOLIO_NAME is not available in DMP

    # verifying Invalid_portfolio does not exist in DMP
    Given  I expect value of column "PORTFOLIO_COUNT_CHECK" in the below SQL query equals to "0":
    """
    SELECT COUNT(DISTINCT 1) AS PORTFOLIO_COUNT_CHECK
    FROM FT_T_ACID ACID
    INNER JOIN FT_T_EXTR EXTR
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    WHERE ACID.ACCT_ALT_ID = '${INVALID_PORTFOLIO}'
    AND ETID.EXEC_TRN_ID = REGEXP_SUBSTR('${NEW_CASH_ID6}','[^.]*')
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND ACID.ACCT_ID_CTXT_TYP  in('ESPORTCDE ','ALTCRTSID ','CRTSID')
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
    AND NTEL.PARM_VAL_TXT LIKE '%${INVALID_PORTFOLIO} BRS AccountAlternateIdentifier%'
    """

  Scenario: Validating the exception in case of PORTFOLIO_NAME is NULL

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 0 to variable "NEW_CASH_ID"

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = REGEXP_SUBSTR('${NEW_CASH_ID}','[^.]*')
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields PORTFOLIOS PORTFOLIO NAMEis not present in the input record.%'
    """

  Scenario: Validating the exception in case of AMOUNT is NULL

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 1 to variable "NEW_CASH_ID"

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = REGEXP_SUBSTR('${NEW_CASH_ID}','[^.]*')
    AND NTEL.CHAR_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, AMOUNTis not present in the input record.%'
    """

  Scenario: Validating the exception in case of CASH_TYPE is NULL

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 2 to variable "NEW_CASH_ID"

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = REGEXP_SUBSTR('${NEW_CASH_ID}','[^.]*')
    AND NTEL.CHAR_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, CASH TYPEis not present in the input record.%'
    """

  Scenario: Validating the exception in case of TRADE_DATE is NULL

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 3 to variable "NEW_CASH_ID"

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = REGEXP_SUBSTR('${NEW_CASH_ID}','[^.]*')
    AND NTEL.CHAR_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, TRADE DATEis not present in the input record.%'
    """

  Scenario: Validating the exception in case of SETTLE_DATE is NULL

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 4 to variable "NEW_CASH_ID"

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.MSG_SEVERITY_CDE = 40
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MAIN_ENTITY_ID = REGEXP_SUBSTR('${NEW_CASH_ID}','[^.]*')
    AND NTEL.CHAR_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, SETTLE DATEis not present in the input record.%'
    """