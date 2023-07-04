# File96-1-2 : BRS to DMP file96 Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-3437
# Current Ticket : https://jira.intranet.asia/browse/TOM-4505
# Requirement Link : https://collaborate.intranet.asia/display/TOM/Intraday+Flows%3A+Cash+Allocations

@gc_interface_cash
@dmp_regression_unittest
@01_tom_4505_brs_dmp_f96
Feature: File96-1: File96 Interface Testing (BRS to DMP) - Positive Flow Validation

  Below Scenarios are handled as part of this feature:
  1. Validation for mandatory fields post File96 load
  2. Validation for other fields as per requirement including status validation

  Scenario: Load file 96 from BRS to DMP

    Given I assign "tests/test-data/Regression-DMP/Intraday/BRS_TO_BNP/Cash/File96/TOM-4505" to variable "testdata.path"
    And I assign "esi_newcash_positive_data.xml" to variable "INPUT_FILE_NAME"
    And I assign "esi_newcash_template.xml" to variable "INPUT_FILE_TEMPLATE"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | NEW_CASH_ID1 | ${TIMESTAMP}0 |
      | NEW_CASH_ID2 | ${TIMESTAMP}1 |
      | NEW_CASH_ID3 | ${TIMESTAMP}2 |
      | NEW_CASH_ID4 | ${TIMESTAMP}3 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all the records are processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "4":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario: Extract each field value from inbound File to Data-Table

    #extracting all the tag values of first record in the file:
    Then I extract below values from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}"  with xpath or tagName at index 0 and assign to variables:
      | NEWCASH_ID                | VAR_NEWCASH_ID                |
      | AMOUNT                    | VAR_AMOUNT                    |
      | CASH_TYPE                 | VAR_CASH_TYPE                 |
      | PORTFOLIOS_PORTFOLIO_NAME | VAR_PORTFOLIOS_PORTFOLIO_NAME |
      | CURRENCY                  | VAR_CURRENCY                  |
      | SETTLE_DATE               | VAR_SETTLE_DATE               |
      | TRADE_DATE                | VAR_TRADE_DATE                |
      | TRANS_KEY                 | VAR_TRANS_KEY                 |
      | STATUS                    | VAR_STATUS                    |
      | TOUCH_COUNT               | VAR_TOUCH_COUNT               |
      | MODIFY_DATE               | VAR_MODIFY_DATE               |
      | CONFIRMED_BY              | VAR_CONFIRMED_BY              |

    And I execute below query and extract values of "EXEC_TRD_ID" into same variables
    """
    SELECT EXTR.EXEC_TRD_ID AS EXEC_TRD_ID FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID = REGEXP_SUBSTR('${VAR_NEWCASH_ID}','[^.]*')
    AND ACID.ACCT_ALT_ID = '${VAR_PORTFOLIOS_PORTFOLIO_NAME}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND ACID.ACCT_ID_CTXT_TYP  in ('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

  Scenario: File96 Load Validations for input field: NET_SETTLE_CAMT with respective transformations in DMP

    Then I expect value of column "NET_SETTLE_CAMT_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS NET_SETTLE_CAMT_CHECK
    FROM FT_T_ETMG ETMG
    JOIN FT_T_EXTR EXTR
    ON EXTR.EXEC_TRD_ID = ETMG.EXEC_TRD_ID
    WHERE ETMG.NET_SETTLE_CAMT = REGEXP_SUBSTR('${VAR_AMOUNT}','[^.]*')
    AND EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: EXEC_TRN_CAT_TYP with respective transformations in DMP

    Then I expect value of column "EXEC_TRN_CAT_TYP_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRN_CAT_TYP = 'SUBSREDM'
    AND EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: CASH_TYPE with respective transformations in DMP

    Then I expect value of column "CASH_TYPE_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CASH_TYPE_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRN_CAT_SUB_TYP = '${VAR_CASH_TYPE}'
    AND EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: PORTFOLIO_NAME with respective transformations in DMP

    Then I expect value of column "PORTFOLIO_NAME_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS PORTFOLIO_NAME_CHECK
    FROM FT_T_ACID ACID
    INNER JOIN FT_T_EXTR EXTR
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ACID.ACCT_ALT_ID = '${VAR_PORTFOLIOS_PORTFOLIO_NAME}'
    AND EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: CURRENCY with respective transformations in DMP

    Then I expect value of column "CURRENCY_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CURRENCY_CHECK
    FROM FT_T_EXTR
    WHERE TRD_CURR_CDE = '${VAR_CURRENCY}'
    AND EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: SETTLE_DATE with respective transformations in DMP

    Then I expect value of column "SETTLE_DATE_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS SETTLE_DATE_CHECK
    FROM FT_T_EXTR
    WHERE SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','MM/DD/YYYY')
    AND EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: TRADE_DATE with respective transformations in DMP

    Then I expect value of column "TRADE_DATE_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT  CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRADE_DATE_CHECK
    FROM FT_T_EXTR
    WHERE TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','MM/DD/YYYY')
    AND EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: TRN_CDE with respective transformations in DMP

    Then I expect value of column "TRN_CDE_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRN_CDE_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRD_ID = '${EXEC_TRD_ID}'
    AND TRN_CDE = 'CSHALL96'
    """

  Scenario: File96 Load Validations for input field: TRD_CQTY with respective transformations in DMP

    Then I expect value of column "TRD_CQTY_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_CQTY_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRD_ID = '${EXEC_TRD_ID}'
    AND TRD_CQTY = 0
    """

  Scenario: File96 Load Validations for input field: TOUCH_COUNT with respective transformations in DMP

    Then I expect value of column "TOUCH_COUNT_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TOUCH_COUNT_CHECK
    FROM FT_T_EXST EXST
    INNER JOIN FT_T_EXTR EXTR
    ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    WHERE EXST.GEN_CNT = '${VAR_TOUCH_COUNT}'
    AND EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: MODIFY_DATE with respective transformations in DMP

    Then I expect value of column "MODIFY_DATE_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS MODIFY_DATE_CHECK
    FROM FT_T_EXST EXST
    INNER JOIN FT_T_EXTR EXTR
    ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    WHERE TO_CHAR(TO_DATE(EXST.STAT_TMS,'dd/MM/YY'),'MM/dd/YYYY') = TO_CHAR(TO_DATE('${VAR_MODIFY_DATE}','MM/dd/YYYY'),'MM/dd/YYYY')
    AND EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: TRANS_KEY with respective transformations in DMP

    Then I expect value of column "TRANS_KEY_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRANS_KEY_CHECK
    FROM FT_T_TTRL TTRL
    WHERE TTRL.PRNT_EXEC_TRD_ID = '${EXEC_TRD_ID}'
    AND TTRL.EXEC_TRN_ID = REGEXP_SUBSTR('${VAR_TRANS_KEY}','[^.]*')
    """

  Scenario: File96 Load Validations for input field: CONFIRMED_BY with respective transformations in DMP

    Then I expect value of column "CONFIRMED_BY_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT  CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CONFIRMED_BY_CHECK
    FROM FT_T_EXTR
    WHERE INPUT_USR_ID = '${VAR_CONFIRMED_BY}'
    AND EXEC_TRD_ID = '${EXEC_TRD_ID}'
    """

  Scenario: File96 Load Validations for input field: EXEC_TRD_STAT_TYP with respective transformations in DMP

    Then I expect value of column "STATUS_NEWM_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS STATUS_NEWM_CHECK
    FROM FT_T_EXST EXST
    INNER JOIN FT_T_EXTR EXTR
    ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    WHERE EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID}'
    AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'
    """

  Scenario: Validate STATUS field with respective transformations in DMP for Cancel transaction
  The status should be stored as 'CANC' in DB when it's value is 'C' in inbound file else it should be 'NEWM'

    Given I extract below values from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}"  with xpath or tagName at index 3 and assign to variables:
      | NEWCASH_ID                | VAR_NEWCASH_ID                |
      | PORTFOLIOS_PORTFOLIO_NAME | VAR_PORTFOLIOS_PORTFOLIO_NAME |

    And I execute below query and extract values of "EXEC_TRD_ID" into same variables
    """
    SELECT EXTR.EXEC_TRD_ID AS EXEC_TRD_ID
    FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID = REGEXP_SUBSTR('${VAR_NEWCASH_ID}','[^.]*')
    AND ACID.ACCT_ALT_ID = '${VAR_PORTFOLIOS_PORTFOLIO_NAME}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND ACID.ACCT_ID_CTXT_TYP  in ('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

    Then I expect value of column "STATUS_CANC_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS STATUS_CANC_CHECK
    FROM FT_T_EXST EXST
    INNER JOIN FT_T_EXTR EXTR
    ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    WHERE EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID}'
    AND EXST.EXEC_TRD_STAT_TYP = 'CANC'
    """