# Requirement Link: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14789845
# Parent Ticket: https://jira.intranet.asia/browse/TOM-3594
# Current Ticket: https://jira.intranet.asia/browse/TOM-4599
#TOM-4708: As part of TOM-4534, we have disabled the segments for ACST and hence the related exceptions will not be thrown.
# Changing the jblg failed and partial count
#TOM-4713: Added Feature History

@gc_interface_positions
@dmp_regression_unittest
@03_tom_4599_bnp_dmp_eod3_positions_fx
Feature: SOD-3 Position FX Interface - Exceptions

  Below Scenarios are handled as part of this feature:
  1. Validate the processing of test exception file
  2. Validate successful exception cases:
  2.a. Validate the exception when mandatory fields are NULL (INSTR_ID, ACCT_ID,VALN_DATE,RUN_DATE,PFOLIO_CCY,ISSUE_CCY,LONG_SHORT_IND)
  2.b. Validate the exception when underlying portfolio do not have defined region

  Scenario: TC01: Load BNP FX Positions to DMP

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Positions/SOD_POS/TOM-4599" to variable "testdata.path"
    And I assign "ESISODP_POS_FX_EXCEPTION_FILE.out" to variable "INPUT_FILE_NAME"
    And I assign "ESISODP_POS_FX_TEMPLATE_FILE_EXCEPTION.out" to variable "INPUT_TEMPLATE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "TEST_DATE_IN"
    And I generate value with date format "mmss" and assign to variable "DYNAMIC_VALUE"

    And I execute below query and extract values of "ACCT_ID_NONLATAM" column into incremental variables
    """
    SELECT * FROM
    (
      SELECT DISTINCT ACCT_ALT_ID AS ACCT_ID_NONLATAM
      FROM FT_T_ACID ACID
      INNER JOIN FT_T_ACST ACST
      ON ACID.ACCT_ID = ACST.ACCT_ID
      INNER JOIN FT_T_ACGU ACGU
      ON ACID.ACCT_ID = ACGU.ACCT_ID
      WHERE ACID.ACCT_ID_CTXT_TYP='BNPPRTID'
      AND ACID.END_TMS IS NULL
      AND ACGU.END_TMS IS NULL
      AND ACST.STAT_DEF_ID ='NPP'
      AND ACST.STAT_CHAR_VAL_TXT ='N'
      AND ACGU.GU_TYP='REGION'
      AND ACGU.GU_CNT =1
      AND ACGU.ACCT_GU_PURP_TYP ='POS_SEGR'
      AND ACGU.GU_ID = 'NONLATAM'
      ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 6
    """

    And I execute below query and extract values of "INSTR_ID_FX" column into incremental variables
    """
    SELECT * FROM
    (
      SELECT DISTINCT ISS_ID AS INSTR_ID_FX
      FROM FT_T_ISID ISID
      INNER JOIN FT_T_ISCL ISCL
      ON ISID.INSTR_ID = ISCL.INSTR_ID
      WHERE ISID.ID_CTXT_TYP='BNPLSTID'
      AND ISID.END_TMS IS NULL
      AND ISCL.END_TMS IS NULL
      AND ISCL.INDUS_CL_SET_ID='BNPASTYP'
      AND ISCL.CL_VALUE = 'FX'
      ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 7
    """

    #File will be created with NULL value one for each row for: INSTR_ID, ACCT_ID,VALN_DATE,RUN_DATE,PFOLIO_CCY,ISSUE_CCY,LONG_SHORT_IND & one portfolio not having defined region
    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_TEMPLATE_NAME}" with below codes from location "${testdata.path}"
      | ACCT_ID_NOREGION | NOREGIONFX |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "FAILED_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_FAILED_CNT AS FAILED_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "7":
    """
    SELECT TASK_PARTIAL_CNT as PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  Scenario Outline: TC02: Validate that system throw exception and should not process the records when "<Description>"

    Then I extract below values for row <Row> from PSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to "SOURCE_ID" column and assign to variables:
      | INSTR_ID      | VAR_INSTR_ID      |
      | TRAN_ID       | VAR_TRAN_ID       |
      | VALN_DATE     | VAR_VALN_DATE     |
      | RUN_DATE      | VAR_RUN_DATE      |
      | ACCT_ID       | VAR_ACCT_ID       |
      | INQUIRY_BASIS | VAR_INQUIRY_BASIS |


    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK  FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND TRID.MAIN_ENTITY_ID = '<MAIN_ENTITY_ID>'
    AND NTEL.CHAR_VAL_TXT LIKE '%<Error_Message>%'
    AND NTEL.MSG_SEVERITY_CDE <> '50'
    AND NTEL.NOTFCN_CNT = '1'
    """

    Examples:
      | Row | Description            | MAIN_ENTITY_ID                                                                                      | Error_Message                                                                                                                                        |
      | 2   | INSTR_ID is NULL       | :${VAR_TRAN_ID}:${VAR_VALN_DATE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS}                | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, SECURITY is not present in the input record.           |
      | 3   | ACCT_ID is NULL        | ${VAR_INSTR_ID}:${VAR_TRAN_ID}:${VAR_VALN_DATE}:${VAR_RUN_DATE}::${VAR_INQUIRY_BASIS}               | Data validation failed in Input file User defined Error thrown! . LATAM NONLATAM FLAG missing for the portfolio                                      |
      | 4   | VALN_DATE is NULL      | ${VAR_INSTR_ID}:${VAR_TRAN_ID}::${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS}                 | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, VALN_DATE is not present in the input record.          |
      | 5   | RUN_DATE is NULL       | ${VAR_INSTR_ID}:${VAR_TRAN_ID}:${VAR_VALN_DATE}::${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS}                | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, RUN_DATE is not present in the input record.           |
      | 6   | PFOLIO_CCY is NULL     | ${VAR_INSTR_ID}:${VAR_TRAN_ID}:${VAR_VALN_DATE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, PORTFOLIO CURRENCY is not present in the input record. |
      | 7   | ISSUE_CCY is NULL      | ${VAR_INSTR_ID}:${VAR_TRAN_ID}:${VAR_VALN_DATE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, SECURITY CURRENCY is not present in the input record.  |
      | 8   | LONG_SHORT_IND is NULL | ${VAR_INSTR_ID}:${VAR_TRAN_ID}:${VAR_VALN_DATE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, LONG_SHORT_IND is not present in the input record.     |
      | 9   | ACCT_ID is No-Region   | ${VAR_INSTR_ID}:${VAR_TRAN_ID}:${VAR_VALN_DATE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} | Data validation failed in Input file User defined Error thrown! . LATAM NONLATAM FLAG missing for the portfolio NOREGIONFX                           |