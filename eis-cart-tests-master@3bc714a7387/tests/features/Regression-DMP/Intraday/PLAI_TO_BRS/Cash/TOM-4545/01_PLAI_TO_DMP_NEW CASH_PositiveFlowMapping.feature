#Ticket link : https://jira.intranet.asia/browse/TOM-4545
#Parent Ticket: https://jira.intranet.asia/browse/TOM-3393
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844973#Test-logicalMapping

@gc_interface_cash
@dmp_regression_unittest
@01_tom_4545_plai_dmp_new_cash
Feature: PLAI to DMP NewCash feed - Field Mapping

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Intraday New Cash Feed from PLAI
  2. Validating fields mapping for GC tables as per Specifications


  Scenario: Load NewCash File

    Given I assign "tests/test-data/Regression-DMP/Intraday/PLAI_TO_BRS/Cash/TOM-4545" to variable "testdata.path"
    And I assign "PLA_FUNDALLOC_PositiveFlow.csv" to variable "INPUT_FILENAME"
    And I assign "PLA_FUNDALLOC_Template_Positive.csv" to variable "INPUTFILE_TEMPLATE"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"


        #Dynamically fetching the portfolio name from DB
    And I execute below query and extract values of "PORTFOLIO_NAME" into same variables
    """
    SELECT * from (SELECT ACCT_ALT_ID as PORTFOLIO_NAME FROM FT_T_ACID WHERE ACCT_ID_CTXT_TYP in ('ESPORTCDE','ALTCRTSID','CRTSID') ORDER BY 1 DESC ) WHERE rownum <= 1
    """

    When I create input file "${INPUT_FILENAME}" using template "${INPUTFILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | EXTERN_NEWCASH_ID1 | ${TIMESTAMP}1 |
      | EXTERN_NEWCASH_ID2 | ${TIMESTAMP}2 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}                          |
      | MESSAGE_TYPE  | ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION |


    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all the records are processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario: Extract EXEC_TRD_ID for each transaction from Database

    Given I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "EXTERN_NEWCASH_ID1" column and assign to variables:
      | EXTERN_NEWCASH_ID1 | VAR_EXTERN_NEWCASH_ID1 |
      | PORTFOLIO          | VAR_PORTFOLIO1         |

    And I execute below query and extract values of "EXEC_TRD_ID_ROW1" into same variables
    """
    SELECT EXTR.EXEC_TRD_ID AS EXEC_TRD_ID_ROW1
    FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID ='${VAR_EXTERN_NEWCASH_ID1}'
    AND EXTR.TRD_ID ='${VAR_EXTERN_NEWCASH_ID1}'
    AND ACID.ACCT_ALT_ID ='${VAR_PORTFOLIO1}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'ESIITRNID'
    AND ACID.ACCT_ID_CTXT_TYP in ('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

    Given I extract below values for row 3 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "EXTERN_NEWCASH_ID1" column and assign to variables:
      | EXTERN_NEWCASH_ID1 | VAR_EXTERN_NEWCASH_ID2 |
      | PORTFOLIO          | VAR_PORTFOLIO2         |

    And I execute below query and extract values of "EXEC_TRD_ID_ROW2" into same variables
    """
    SELECT EXTR.EXEC_TRD_ID AS EXEC_TRD_ID_ROW2
    FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID ='${VAR_EXTERN_NEWCASH_ID2}'
    AND EXTR.TRD_ID ='${VAR_EXTERN_NEWCASH_ID2}'
    AND ACID.ACCT_ALT_ID ='${VAR_PORTFOLIO2}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'ESIITRNID'
    AND ACID.ACCT_ID_CTXT_TYP in ('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

  Scenario: Extract each field value from inbound File to Data-Table

    When I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "EXTERN_NEWCASH_ID1" column and assign to variables:
      | AMOUNT      | VAR_AMOUNT      |
      | CURRENCY    | VAR_CURRENCY    |
      | CASH_TYPE   | VAR_CASH_TYPE   |
      | SETTLE_DATE | VAR_SETTLE_DATE |
      | TRADE_DATE  | VAR_TRADE_DATE  |
      | CANCEL      | VAR_CANCEL      |
      | COMMENTS    | VAR_COMMENTS    |

  Scenario Outline: PLAI NewCash1 Feed Validations for <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

    Examples: Inbound file to DMP field mapping validation
      | Column                 | Query                                                                                                                                                                                                                                                      |
      | PORTFOLIO_CHECK        | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS PORTFOLIO_CHECK FROM FT_T_ACID ACID INNER JOIN FT_T_EXTR EXTR ON ACID.ACCT_ID=EXTR.ACCT_ID WHERE ACID.ACCT_ALT_ID = '${VAR_PORTFOLIO1}' AND EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}' |
      | AMOUNT_CHECK           | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS AMOUNT_CHECK FROM FT_T_ETMG WHERE NET_SETTLE_CAMT = REPLACE('${VAR_AMOUNT}',',','') AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                          |
      | CURRENCY_CHECK         | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CURRENCY_CHECK FROM FT_T_EXTR WHERE SETTLE_CURR_CDE ='${VAR_CURRENCY}' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                       |
      | SETTLE_DATE_CHECK      | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS SETTLE_DATE_CHECK FROM FT_T_EXTR WHERE SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','DD-MON-YY') AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                |
      | TRADE_DATE_CHECK       | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRADE_DATE_CHECK FROM FT_T_EXTR WHERE TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','DD-MON-YY')AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                      |
      | COMMENTS_CHECK         | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS COMMENTS_CHECK FROM FT_T_EXTR WHERE TRD_LEGEND_TXT = '${VAR_COMMENTS}' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                       |
      | EXEC_TRN_CAT_TYP_CHECK | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK FROM FT_T_EXTR WHERE EXEC_TRN_CAT_TYP ='NEW CASH' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                     |
      | TRN_CDE_CHECK          | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRN_CDE_CHECK FROM FT_T_EXTR WHERE TRN_CDE ='ESIICASHTXN' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                                    |
      | TRD_CQTY_CHECK         | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_CQTY_CHECK FROM FT_T_EXTR WHERE TRD_CQTY =0 AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                                              |
      | CANCEL_NEWM_CHECK      | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CANCEL_NEWM_CHECK FROM FT_T_EXST WHERE EXEC_TRD_STAT_TYP ='NEWM' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                             |
      | CASH_TYPE_CASHIN_CHECK | SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CASH_TYPE_CASHIN_CHECK FROM FT_T_EXTR WHERE EXEC_TRN_CL_TYP ='C' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW1}'                                                                             |

  Scenario: Validate CANCEL field with respective transformations in DMP for Cancel transaction
  The status should be stored as 'CANC' in DB when it's value is 'Y' in inbound file else it should be 'NEWM'

    Then I expect value of column "CANCEL_CANC_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CANCEL_CANC_CHECK FROM FT_T_EXST WHERE EXEC_TRD_STAT_TYP ='CANC' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW2}'
    """

  Scenario: Validate CASH_TYPE field with respective transformations in DMP for CashOut transaction
  The CASH_TYPE should be stored as 'C' in DB when it is CASHIN and if CASHOUT it should be stored as 'D'

    Then I expect value of column "CASH_TYPE_CASHIN_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS CASH_TYPE_CASHIN_CHECK FROM FT_T_EXTR WHERE EXEC_TRN_CL_TYP ='D' AND EXEC_TRD_ID = '${EXEC_TRD_ID_ROW2}'
    """