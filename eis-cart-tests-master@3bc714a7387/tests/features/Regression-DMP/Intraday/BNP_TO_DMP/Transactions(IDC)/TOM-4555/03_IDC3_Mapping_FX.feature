#Parent Ticket: https://jira.intranet.asia/browse/TOM-1395
#Current Ticket: https://jira.intranet.asia/browse/TOM-4555
#Requirement: https://collaborate.intranet.asia/pages/viewpage.action?pageId=24939361

@gc_interface_cash
@dmp_regression_unittest
@03_tom_4555_bnp_dmp_idc3
Feature: IDC-3 - Intra Day Cash - Transaction File - FX

  Below Scenarios are handled as part of this feature:
  1. Validate the successful processing (No-Exception) of BNP-to-DMP Intraday Cash File (FX)
  2. Validation for all mandatory fields post processing for new and cancelled trade

  Scenario: TC_01: Initializing variables and generating the IDC-3 Cash test file for verification
    Given I assign "tests/test-data/Regression-DMP/Intraday/BNP_TO_DMP/Transactions(IDC)/TOM-4555" to variable "testdata.path"
    And I assign "ESIINTRADAY_TRN_TEST_FILE_FX.out" to variable "INPUT_FILENAME_FX"
    And I assign "ESIINTRADAY_TRN_TEMPLATE_FX.out" to variable "INPUT_TEMPLATE_FX"
    And I generate value with date format "HHmmss" and assign to variable "TIMESTAMP"
    And I execute below query and extract values of "ACCT_ID" column into incremental variables
    """
    SELECT ACCT_ALT_ID AS ACCT_ID
    FROM ( SELECT T.*, ROWNUM rnum
    FROM ( SELECT DISTINCT(ACCT_ALT_ID) FROM FT_T_ACID WHERE END_TMS IS NULL AND ACCT_ID_CTXT_TYP = 'BNPPRTID') T
    WHERE ROWNUM <= 138 )
    WHERE rnum >= 135
    """

    And I execute below query and extract values of "INSTR_ID" column into incremental variables
    """
    SELECT ISS_ID AS INSTR_ID
    FROM ( SELECT T.*, ROWNUM rnum
    FROM ( SELECT DISTINCT(ISS_ID) FROM FT_T_ISID WHERE END_TMS IS NULL AND ID_CTXT_TYP='BNPLSTID') T
    WHERE ROWNUM <= 4988 )
    WHERE rnum >= 4985
    """

  Scenario: TC_02: Processing the IDC-3 Cash test file for verification
    When I create input file "${INPUT_FILENAME_FX}" using template "${INPUT_TEMPLATE_FX}" with below codes from location "${testdata.path}"
      | DYNAMIC_CODE | ${TIMESTAMP} |
      | PORT_VAL1    | ${ACCT_ID1}  |
      | PORT_VAL2    | ${ACCT_ID2}  |
      | PORT_VAL3    | ${ACCT_ID3}  |
      | PORT_VAL4    | ${ACCT_ID4}  |
      | SEC_VAL1     | ${INSTR_ID1} |
      | SEC_VAL2     | ${INSTR_ID2} |
      | SEC_VAL3     | ${INSTR_ID3} |
      | SEC_VAL4     | ${INSTR_ID4} |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_FX} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_FX}                 |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

    And I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: TC_03: Verify no exceptions should be thrown post processing of BNP-to-DMP Intraday Cash File for FX & total records are loaded from file

    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      """
    Then I expect value of column "PROCESSED_RECORDS" in the below SQL query equals to "4":
      """
      SELECT TASK_SUCCESS_CNT AS PROCESSED_RECORDS FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: Extracting existing data for the first record in the input file

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME_FX}" in local folder "${testdata.path}/testdata" and assign to variables:
      | TRADE_DATE            | VAR_TRADE_DATE            |
      | SETT_DATE             | VAR_SETT_DATE             |
      | NOTES                 | VAR_NOTES                 |
      | BNP_SOURCE_TRAN_EV_ID | VAR_BNP_SOURCE_TRAN_EV_ID |
      | SETT_CCY              | VAR_SETT_CCY              |
      | BNP_CASH_IMPACT_CODE  | VAR_BNP_CASH_IMPACT_CODE  |
      | ENTRY_DATE            | VAR_ENTRY_DATE            |
      | DWH_LAST_UPD_TMS      | VAR_DWH_LAST_UPD_TMS      |
      | NET_SETT_AMT_L        | VAR_NET_SETT_AMT_L        |
      | BNP_SOURCE_TRAN_ID    | VAR_BNP_SOURCE_TRAN_ID    |
      | CANCEL_IND            | VAR_CANCEL_IND_NEWM       |
      | HIP_BROKER_CODE       | VAR_HIP_BROKER_CODE       |

    And I extract below values for row 3 from PSV file "${INPUT_FILENAME_FX}" in local folder "${testdata.path}/testdata" and assign to variables:
      | CANCEL_IND | VAR_CANCEL_IND_CANC |

  Scenario Outline: TC_04: Intraday Cash File (FX) Validations for input field: <ValidationStatus> :

    Then I expect value of column "<ValidationStatus>" in the below SQL query equals to "PASS":
    """
    <SQL>
    """
    Examples: Expecting 'Pass' for each field from New Cash File vs Database
    # 'CNTPRTY_ID_CHECK' is for FX only
      | ValidationStatus             | SQL                                                                                                                                                                                                                                                                                                                                                                                  |
      | INSTR_ID_CHECK               | SELECT CASE WHEN COUNT(INSTR_ID) =1 THEN 'PASS' ELSE 'FAIL' END AS INSTR_ID_CHECK FROM FT_T_ISID WHERE ISS_ID='${INSTR_ID1}' AND ID_CTXT_TYP='BNPLSTID' AND END_TMS IS NULL                                                                                                                                                                                                          |
      | ACCT_ID_CHECK                | SELECT CASE WHEN COUNT(ACCT_ID) =1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_ID_CHECK FROM FT_T_ACID WHERE ACCT_ALT_ID='${ACCT_ID1}' AND ACCT_ID_CTXT_TYP='BNPPRTID' AND END_TMS IS NULL                                                                                                                                                                                                   |
      | TRN_CDE_CHECK                | SELECT CASE WHEN COUNT(DISTINCT(R.TRN_CDE)) =1 THEN 'PASS' ELSE 'FAIL' END AS TRN_CDE_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.TRN_CDE LIKE 'BNPCASHTXN'                                                                                                                                  |
      | EXEC_TRN_CAT_SUB_TYP_CHECK   | SELECT CASE WHEN COUNT(DISTINCT(R.EXEC_TRN_CAT_SUB_TYP)) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_SUB_TYP_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.EXEC_TRN_CAT_SUB_TYP LIKE 'FFXP'                                                                                                 |
      | EXEC_TRN_CAT_TYP_CHECK       | SELECT CASE WHEN COUNT(DISTINCT(R.EXEC_TRN_CAT_TYP)) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.EXEC_TRN_CAT_TYP LIKE 'FX'                                                                                                               |
      | TRD_DTE_CHECK                | SELECT CASE WHEN COUNT(DISTINCT(R.TRD_DTE)) =1 THEN 'PASS' ELSE 'FAIL' END AS TRD_DTE_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','YYYY-MON-DD')                                                                                                       |
      | SETTLE_DTE_CHECK             | SELECT CASE WHEN COUNT(DISTINCT(R.SETTLE_DTE)) =1 THEN 'PASS' ELSE 'FAIL' END AS SETTLE_DTE_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.SETTLE_DTE = TO_DATE('${VAR_SETT_DATE}','YYYY-MON-DD')                                                                                               |
      | TRD_LEGEND_TXT_CHECK         | SELECT CASE WHEN COUNT(DISTINCT(R.TRD_LEGEND_TXT)) =1 THEN 'PASS' ELSE 'FAIL' END AS TRD_LEGEND_TXT_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.TRD_LEGEND_TXT = '${VAR_NOTES}'                                                                                                              |
      | SETTLE_CURR_CDE_CHECK        | SELECT CASE WHEN COUNT(DISTINCT(R.SETTLE_CURR_CDE)) =1 THEN 'PASS' ELSE 'FAIL' END AS SETTLE_CURR_CDE_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.SETTLE_CURR_CDE = '${VAR_SETT_CCY}'                                                                                                        |
      | EXEC_TRN_CL_TYP_CHECK        | SELECT CASE WHEN COUNT(DISTINCT(R.EXEC_TRN_CL_TYP)) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CL_TYP_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.EXEC_TRN_CL_TYP = '${VAR_BNP_CASH_IMPACT_CODE}'                                                                                            |
      | INPUT_APPL_TMS_CHECK         | SELECT CASE WHEN COUNT(DISTINCT(R.INPUT_APPL_TMS)) =1 THEN 'PASS' ELSE 'FAIL' END AS INPUT_APPL_TMS_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.INPUT_APPL_TMS = TO_DATE('${VAR_ENTRY_DATE}','YYYY-MON-DD HH24:MI:SS')                                                                       |
      | STAT_TMS_CHECK               | SELECT CASE WHEN COUNT(DISTINCT EXST.STAT_TMS) =1 THEN 'PASS' ELSE 'FAIL' END AS STAT_TMS_CHECK FROM FT_T_EXST EXST JOIN FT_T_EXTR EXTR ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID JOIN FT_T_ISID ISID ON EXTR.INSTR_ID = ISID.INSTR_ID WHERE ISID.ISS_ID='${INSTR_ID1}' AND ISID.ID_CTXT_TYP='BNPLSTID' AND EXST.STAT_TMS = TO_DATE('${VAR_DWH_LAST_UPD_TMS}','YYYY-MON-DD HH24:MI:SS') |
      | NET_SETTLE_CAMT_CHECK        | SELECT CASE WHEN COUNT(DISTINCT (M.NET_SETTLE_CAMT)) =1 THEN 'PASS' ELSE 'FAIL' END AS NET_SETTLE_CAMT_CHECK FROM FT_T_ISID S JOIN FT_T_EXTR R ON S.INSTR_ID = R.INSTR_ID JOIN FT_T_ETMG M ON R.EXEC_TRD_ID = M.EXEC_TRD_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND M.NET_SETTLE_CAMT = '${VAR_NET_SETT_AMT_L}'                                               |
      | EXEC_TRN_ID_CHECK            | SELECT CASE WHEN COUNT(*) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_ID_CHECK FROM FT_T_ETID WHERE EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_ID}' AND EXEC_TRN_ID_CTXT_TYP = 'BNPTRNID'                                                                                                                                                                                                   |
      | EXEC_TRN_ID_CHECK2           | SELECT CASE WHEN COUNT(*) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_ID_CHECK2 FROM FT_T_ETID WHERE EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}' AND EXEC_TRN_ID_CTXT_TYP = 'BNPTRNEVID'                                                                                                                                                                                             |
      | EXEC_TRD_STAT_TYP_CHECK_NEWM | SELECT CASE WHEN COUNT (DISTINCT EXST.EXEC_TRD_STAT_TYP) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRD_STAT_TYP_CHECK_NEWM FROM FT_T_EXST EXST JOIN FT_T_EXTR EXTR ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID JOIN FT_T_ISID ISID ON EXTR.INSTR_ID = ISID.INSTR_ID WHERE ISID.ISS_ID='${INSTR_ID1}' AND ISID.ID_CTXT_TYP='BNPLSTID' AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'                     |
      | EXEC_TRD_STAT_TYP_CHECK_CANC | SELECT CASE WHEN COUNT (DISTINCT EXST.EXEC_TRD_STAT_TYP) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRD_STAT_TYP_CHECK_CANC FROM FT_T_EXST EXST JOIN FT_T_EXTR EXTR ON EXST.EXEC_TRD_ID = EXTR.EXEC_TRD_ID JOIN FT_T_ISID ISID ON EXTR.INSTR_ID = ISID.INSTR_ID WHERE ISID.ISS_ID='${INSTR_ID2}' AND ISID.ID_CTXT_TYP='BNPLSTID' AND EXST.EXEC_TRD_STAT_TYP = 'CANC'                     |
      | CNTPRTY_ID_CHECK             | SELECT CASE WHEN COUNT (DISTINCT TRCP.CNTPRTY_ID) =1 THEN 'PASS' ELSE 'FAIL' END AS CNTPRTY_ID_CHECK FROM FT_T_TRCP TRCP JOIN FT_T_EXTR EXTR ON TRCP.EXEC_TRD_ID = EXTR.EXEC_TRD_ID JOIN FT_T_ISID ISID ON EXTR.INSTR_ID = ISID.INSTR_ID WHERE ISID.ISS_ID='${INSTR_ID1}' AND TRCP.CNTPRTY_ID = '${VAR_HIP_BROKER_CODE}' AND TRCP.CNTPRTY_ID_CTXT_TYP = 'HIPBROKER'                  |