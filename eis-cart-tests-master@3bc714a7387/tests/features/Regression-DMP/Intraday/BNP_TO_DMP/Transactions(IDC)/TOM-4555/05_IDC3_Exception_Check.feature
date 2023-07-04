#Parent Ticket: https://jira.intranet.asia/browse/TOM-1395
#Current Ticket: https://jira.intranet.asia/browse/TOM-4555
#Requirement: https://collaborate.intranet.asia/pages/viewpage.action?pageId=24939361

@gc_interface_cash
@dmp_regression_unittest
@05_tom_4555_bnp_dmp_idc3
Feature: IDC-3 - Intra Day Cash - Transaction File - Exceptions

  Below Scenarios are handled as part of this feature:
  1. Validate the processing of BNP-to-DMP Intraday Cash File for : 'NEW CASH','MISC','COLLAT/MARGIN','FX' with missing mandatory fields
  2. Validate the exception messages for each trade type

  Scenario: TC_01: Initializing variables and generating the IDC-3 Cash test file for verification
    Given I assign "tests/test-data/Regression-DMP/Intraday/BNP_TO_DMP/Transactions(IDC)/TOM-4555" to variable "testdata.path"
    And I assign "ESIINTRADAY_TRN_TEST_FILE_EX.out" to variable "INPUT_FILENAME_EX"
    And I assign "ESIINTRADAY_TRN_TEMPLATE_EXCP.out" to variable "INPUT_TEMPLATE_EX"
    And I generate value with date format "HHmmss" and assign to variable "TIMESTAMP"
    And I execute below query and extract values of "ACCT_ID" column into incremental variables
        """
        SELECT ACCT_ALT_ID AS ACCT_ID
        FROM ( SELECT T.*, ROWNUM rnum
        FROM ( SELECT DISTINCT(ACCT_ALT_ID) FROM FT_T_ACID WHERE END_TMS IS NULL AND ACCT_ID_CTXT_TYP = 'BNPPRTID') T
        WHERE ROWNUM <= 96 )
        WHERE rnum >= 92
        """
    And I execute below query and extract values of "INSTR_ID" column into incremental variables
        """
        SELECT ISS_ID AS INSTR_ID
        FROM ( SELECT T.*, ROWNUM rnum
        FROM ( SELECT DISTINCT(ISS_ID) FROM FT_T_ISID WHERE END_TMS IS NULL AND ID_CTXT_TYP='BNPLSTID') T
        WHERE ROWNUM <= 4946 )
        WHERE rnum >= 4942
        """

  Scenario: TC_02: Processing the IDC-3 Cash test file for verification
    When I create input file "${INPUT_FILENAME_EX}" using template "${INPUT_TEMPLATE_EX}" with below codes from location "${testdata.path}"
      | DYNAMIC_CODE | ${TIMESTAMP} |
      | SEC_VAL1     | ${INSTR_ID1} |
      | SEC_VAL2     | ${INSTR_ID2} |
      | SEC_VAL3     | ${INSTR_ID3} |
      | SEC_VAL4     | ${INSTR_ID4} |
      | SEC_VAL5     | ${INSTR_ID5} |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EX} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_EX}                 |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

    And I extract new job id from jblg table into a variable "JOB_ID"

  Scenario Outline: TC_03: Validate that system throw exception and should not process the records when "<Description>"

    Then I extract below values for row <Row> from PSV file "${INPUT_FILENAME_EX}" in local folder "${testdata.path}/testdata" with reference to "SOURCE_ID" column and assign to variables:
      | BNP_SOURCE_TRAN_ID | VAR_BNP_SOURCE_TRAN_ID |

    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
  """
  SELECT COUNT(*) AS EXCEPTION_MSG_CHK
  FROM FT_T_NTEL NTEL
  INNER JOIN FT_T_TRID TRID
  ON NTEL.TRN_ID=TRID.TRN_ID
  WHERE TRID.JOB_ID ='${JOB_ID}'
  AND NTEL.MSG_SEVERITY_CDE = 40
  AND NTEL.NOTFCN_ID = 60001
  AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
  AND NTEL.MAIN_ENTITY_ID = '${VAR_BNP_SOURCE_TRAN_ID}'
  AND NTEL.CHAR_VAL_TXT LIKE '%<Error_Message>%'
  """

    Examples:
      | Row | Description                          | Error_Message                                                                                                                                                                                                                                            |
      | 2   | Mandatory fields for NewCash is NULL | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields ACCT ID, BNP CASH IMPACT CODE, NET SETT AMT L, SETT CCY, SETT DATE, TRADE DATE is not present in the input record.                                    |
      | 3   | Mandatory fields for Collat is NULL  | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields ACCT ID, BNP CASH IMPACT CODE, NET SETT AMT L, SETT CCY, SETT DATE, TRADE DATE is not present in the input record.                                    |
      | 4   | Mandatory fields for Margin is NULL  | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields ACCT ID, BNP CASH IMPACT CODE, NET SETT AMT L, SETT CCY, SETT DATE, TRADE DATE is not present in the input record.                                    |
      | 5   | Mandatory fields for FX is NULL      | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields ACCT ID, BNP SOURCE TRAN EV ID, HIP BROKER CODE, HIP BROKER NAME, NET SETT AMT L, SETT CCY, SETT DATE, TRADE DATE is not present in the input record. |
      | 6   | Mandatory fields for Misc is NULL    | Missing Data Exception:- User defined Error thrown! . Cannot process the record as required fields ACCT ID, NET SETT AMT L, SETT CCY, SETT DATE, TRADE DATE is not present in the input record.                                                          |
