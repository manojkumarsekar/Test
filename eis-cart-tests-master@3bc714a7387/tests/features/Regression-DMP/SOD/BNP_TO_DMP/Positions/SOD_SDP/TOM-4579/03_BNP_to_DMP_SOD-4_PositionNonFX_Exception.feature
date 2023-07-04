# TOM-4579
# SOD-4_PositionNonFX : BNP to DMP Position Non FX Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-1225
# Current Ticket : https://jira.intranet.asia/browse/TOM-4579
# Requirement Link : https://collaborate.intranet.asia/display/TOM/SOD+Flows%3A+SOD+Positions+for+Reconciliation
#TOM-4708: As part of TOM-4534, we have disabled the segments for ACST and hence the related exceptions will not be thrown.
# Changing the jblg failed and partial count
#TOM-4713: Added Feature History

@gc_interface_positions
@dmp_regression_unittest
@03_tom_4579_bnp_dmp_sod4_positions_nfx
Feature: SOD-4 Position NonFX Interface - Exception

  Below Scenarios are handled as part of this feature:
  1. Validate that system throw exception and should not process the the records when:
  a)INSTR_ID is NULL
  b)ACCT_ID is NULL
  c)RUN_DATE is NULL
  d)PFOLIO_CCY is NULL
  e)VALN_DATE is NULL
  f)LONG_SHORT_IND is NULL
  g)ISSUE_CCY is NULL
  h)ASSET_TYPE is NULL
  2. Validate that system throw exception and should not process the records when LATAM/NONLATAM FLAG is missing for the portfolio

  Scenario: Load BNP NON FX Positions to DMP and validate the exception

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Positions/SOD_SDP/TOM-4579" to variable "testdata.path"
    And I assign "ESISODP_SDP_NonFX_exception_data.out" to variable "INPUT_FILE_NAME"
    And I assign "ESISODP_SDP_exception_template.out" to variable "INPUT_FILE_EXCEPTION_TEMPLATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "TEST_DATE_IN"

    And I execute below query and extract values of "ACCT_ID_NONLATAM" column into incremental variables
    """
    SELECT * FROM
    (SELECT DISTINCT ACCT_ALT_ID AS ACCT_ID_NONLATAM
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
    WHERE rownum <= 7
    """

    And I execute below query and extract values of "INSTR_ID_STOCK" column into incremental variables
    """
    SELECT * FROM
    (SELECT DISTINCT ISS_ID AS INSTR_ID_STOCK
     FROM FT_T_ISID ISID
     INNER JOIN FT_T_ISCL ISCL
     ON ISID.INSTR_ID = ISCL.INSTR_ID
     WHERE ISID.ID_CTXT_TYP='BNPLSTID'
     AND ISID.END_TMS IS NULL
     AND ISCL.END_TMS IS NULL
     AND ISCL.INDUS_CL_SET_ID='BNPASTYP'
     AND ISCL.CL_VALUE ='STOCK'
     ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 8
    """

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_EXCEPTION_TEMPLATE}" with below codes from location "${testdata.path}"
      | NULL_INSTR_ID       |          |
      | NULL_ACCT_ID        |          |
      | NULL_RUN_DATE       |          |
      | NULL_PFOLIO_CCY     |          |
      | NULL_VALN_DATE      |          |
      | NULL_LONG_SHORT_IND |          |
      | NULL_ISSUE_CCY      |          |
      | NULL_ASSET_TYPE     |          |
      | ACCT_ID_NOREGION    | NOREGION |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # verifying that file load job is not successful when LATAM/NONLATAM FLAG is missing for the portfolio and Portoflio and Security columns are NULL
    Then I expect value of column "FAILED_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_FAILED_CNT AS FAILED_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

   # verifying that file load job is not successful when mandatory columns are NULL
    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "7":
    """
    SELECT TASK_PARTIAL_CNT as PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  Scenario Outline: Validate that system throw exception and should not process the records when "<Description>"

    Then I extract below values for row <Row> from PSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to "SOURCE_ID" column and assign to variables:
      | INSTR_ID      | VAR_INSTR_ID      |
      | VALN_DATE     | VAR_VALN_DATE     |
      | RUN_DATE      | VAR_RUN_DATE      |
      | ACCT_ID       | VAR_ACCT_ID       |
      | INQUIRY_BASIS | VAR_INQUIRY_BASIS |
      | BALANCE_TYPE  | VAR_BALANCE_TYPE  |

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHK
    FROM FT_T_NTEL NTEL
    INNER JOIN FT_T_TRID TRID
    ON NTEL.TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID ='${JOB_ID}'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND TRID.MAIN_ENTITY_ID = '<MAIN_ENTITY_ID>'
    AND NTEL.CHAR_VAL_TXT LIKE '%<Error_Message>%'
    """

    Examples:
      | Row | Description                                      | Error_Message                                                                                                                                        | MAIN_ENTITY_ID                                                                                           |
      | 2   | LATAM/NONLATAM FLAG is missing for the portfolio | Data validation failed in Input file User defined Error thrown! . LATAM NONLATAM FLAG missing for the portfolio ${VAR_ACCT_ID}                       | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} |
      | 3   | INSTR_ID is NULL                                 | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, SECURITY is not present in the input record.           | :${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS}                |
      | 4   | ACCT_ID is NULL                                  | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, PORTFOLIO is not present in the input record.          | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}::${VAR_INQUIRY_BASIS}               |
      | 5   | RUN_DATE is NULL                                 | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fieldsRUN_DATE is not present in the input record.             | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}::${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS}                |
      | 6   | PFOLIO_CCY is NULL                               | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, PORTFOLIO CURRENCY is not present in the input record. | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} |
      | 7   | VALN_DATE is NULL                                | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, VALUATION_DATE is not present in the input record.     | ${VAR_INSTR_ID}::${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS}                 |
      | 8   | LONG_SHORT_IND is NULL                           | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, LONG_SHORT_IND is not present in the input record.     | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} |
      | 9   | ISSUE_CCY is NULL                                | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, ISSUE_CCY is not present in the input record.          | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} |
      | 10  | ASSET_TYPE is NULL                               | Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields ASSET_TYPE is not present in the input record.          | ${VAR_INSTR_ID}:${VAR_VALN_DATE}:${VAR_BALANCE_TYPE}:${VAR_RUN_DATE}:${VAR_ACCT_ID}:${VAR_INQUIRY_BASIS} |