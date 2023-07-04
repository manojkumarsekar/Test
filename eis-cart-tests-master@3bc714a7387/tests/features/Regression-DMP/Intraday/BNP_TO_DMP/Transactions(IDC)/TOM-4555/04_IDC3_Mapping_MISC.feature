#Parent Ticket: https://jira.intranet.asia/browse/TOM-1395
#Current Ticket: https://jira.intranet.asia/browse/TOM-4555
#Requirement: https://collaborate.intranet.asia/pages/viewpage.action?pageId=24939361


@gc_interface_cash
@dmp_regression_unittest
@04_tom_4555_bnp_dmp_idc3
Feature: IDC-3 - Intra Day Cash - Transaction File - Misc

  Below Scenarios are handled as part of this feature:
  1. Validate the successful processing (No-Exception) of BNP-to-DMP Intraday Cash File (Misc)
  2. Validation for all mandatory fields post processing for new and cancelled trade

  Scenario: TC_01: Initializing variables and generating the IDC-3 Cash test file for verification
    Given I assign "tests/test-data/Regression-DMP/Intraday/BNP_TO_DMP/Transactions(IDC)/TOM-4555" to variable "testdata.path"
    And I assign "ESIINTRADAY_TRN_TEST_FILE_MI.out" to variable "INPUT_FILENAME_MI"
    And I assign "ESIINTRADAY_TRN_TEMPLATE_MISC.out" to variable "INPUT_TEMPLATE_MISC"
    And I generate value with date format "HHmmss" and assign to variable "TIMESTAMP"
    And I execute below query and extract values of "ACCT_ID" column into incremental variables
    """
    SELECT ACCT_ALT_ID AS ACCT_ID
    FROM ( SELECT T.*, ROWNUM rnum
    FROM ( SELECT DISTINCT(ACCT_ALT_ID) FROM FT_T_ACID WHERE END_TMS IS NULL AND ACCT_ID_CTXT_TYP = 'BNPPRTID') T
    WHERE ROWNUM <= 134 )
    WHERE rnum >= 97
    """

    And I execute below query and extract values of "INSTR_ID" column into incremental variables
    """
    SELECT ISS_ID AS INSTR_ID
    FROM ( SELECT T.*, ROWNUM rnum
    FROM ( SELECT DISTINCT(ISS_ID) FROM FT_T_ISID WHERE END_TMS IS NULL AND ID_CTXT_TYP='BNPLSTID') T
    WHERE ROWNUM <= 4984 )
    WHERE rnum >= 4947
    """

  Scenario: TC_02: Processing the IDC-3 Cash test file for verification
    When I create input file "${INPUT_FILENAME_MI}" using template "${INPUT_TEMPLATE_MISC}" with below codes from location "${testdata.path}"
      | DYNAMIC_CODE | ${TIMESTAMP}  |
      | PORT_VAL1    | ${ACCT_ID1}   |
      | PORT_VAL2    | ${ACCT_ID2}   |
      | PORT_VAL3    | ${ACCT_ID3}   |
      | PORT_VAL4    | ${ACCT_ID4}   |
      | PORT_VAL5    | ${ACCT_ID5}   |
      | PORT_VAL6    | ${ACCT_ID6}   |
      | PORT_VAL7    | ${ACCT_ID7}   |
      | PORT_VAL8    | ${ACCT_ID8}   |
      | PORT_VAL9    | ${ACCT_ID9}   |
      | PORT_VAL10   | ${ACCT_ID10}  |
      | PORT_VAL11   | ${ACCT_ID11}  |
      | PORT_VAL12   | ${ACCT_ID12}  |
      | PORT_VAL13   | ${ACCT_ID13}  |
      | PORT_VAL14   | ${ACCT_ID14}  |
      | PORT_VAL15   | ${ACCT_ID15}  |
      | PORT_VAL16   | ${ACCT_ID16}  |
      | PORT_VAL17   | ${ACCT_ID17}  |
      | PORT_VAL18   | ${ACCT_ID18}  |
      | PORT_VAL19   | ${ACCT_ID19}  |
      | PORT_VAL20   | ${ACCT_ID20}  |
      | PORT_VAL21   | ${ACCT_ID21}  |
      | PORT_VAL22   | ${ACCT_ID22}  |
      | PORT_VAL23   | ${ACCT_ID23}  |
      | PORT_VAL24   | ${ACCT_ID24}  |
      | PORT_VAL25   | ${ACCT_ID25}  |
      | PORT_VAL26   | ${ACCT_ID26}  |
      | PORT_VAL27   | ${ACCT_ID27}  |
      | PORT_VAL28   | ${ACCT_ID28}  |
      | PORT_VAL29   | ${ACCT_ID29}  |
      | PORT_VAL30   | ${ACCT_ID30}  |
      | PORT_VAL31   | ${ACCT_ID31}  |
      | PORT_VAL32   | ${ACCT_ID32}  |
      | PORT_VAL33   | ${ACCT_ID33}  |
      | PORT_VAL34   | ${ACCT_ID34}  |
      | PORT_VAL35   | ${ACCT_ID35}  |
      | PORT_VAL36   | ${ACCT_ID36}  |
      | PORT_VAL37   | ${ACCT_ID37}  |
      | PORT_VAL38   | ${ACCT_ID38}  |
      | SEC_VAL1     | ${INSTR_ID1}  |
      | SEC_VAL2     | ${INSTR_ID2}  |
      | SEC_VAL3     | ${INSTR_ID3}  |
      | SEC_VAL4     | ${INSTR_ID4}  |
      | SEC_VAL5     | ${INSTR_ID5}  |
      | SEC_VAL6     | ${INSTR_ID6}  |
      | SEC_VAL7     | ${INSTR_ID7}  |
      | SEC_VAL8     | ${INSTR_ID8}  |
      | SEC_VAL9     | ${INSTR_ID9}  |
      | SEC_VAL10    | ${INSTR_ID10} |
      | SEC_VAL11    | ${INSTR_ID11} |
      | SEC_VAL12    | ${INSTR_ID12} |
      | SEC_VAL13    | ${INSTR_ID13} |
      | SEC_VAL14    | ${INSTR_ID14} |
      | SEC_VAL15    | ${INSTR_ID15} |
      | SEC_VAL16    | ${INSTR_ID16} |
      | SEC_VAL17    | ${INSTR_ID17} |
      | SEC_VAL18    | ${INSTR_ID18} |
      | SEC_VAL19    | ${INSTR_ID19} |
      | SEC_VAL20    | ${INSTR_ID20} |
      | SEC_VAL21    | ${INSTR_ID21} |
      | SEC_VAL22    | ${INSTR_ID22} |
      | SEC_VAL23    | ${INSTR_ID23} |
      | SEC_VAL24    | ${INSTR_ID24} |
      | SEC_VAL25    | ${INSTR_ID25} |
      | SEC_VAL26    | ${INSTR_ID26} |
      | SEC_VAL27    | ${INSTR_ID27} |
      | SEC_VAL28    | ${INSTR_ID28} |
      | SEC_VAL29    | ${INSTR_ID29} |
      | SEC_VAL30    | ${INSTR_ID30} |
      | SEC_VAL31    | ${INSTR_ID31} |
      | SEC_VAL32    | ${INSTR_ID32} |
      | SEC_VAL33    | ${INSTR_ID33} |
      | SEC_VAL34    | ${INSTR_ID34} |
      | SEC_VAL35    | ${INSTR_ID35} |
      | SEC_VAL36    | ${INSTR_ID36} |
      | SEC_VAL37    | ${INSTR_ID37} |
      | SEC_VAL38    | ${INSTR_ID38} |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_MI} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_MI}                 |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

    And I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: TC_03: Verify no exceptions should be thrown post processing of BNP-to-DMP Intraday Cash File for Misc & total records are loaded from file

    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      """
    Then I expect value of column "PROCESSED_RECORDS" in the below SQL query equals to "38":
      """
      SELECT TASK_SUCCESS_CNT AS PROCESSED_RECORDS FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: Extracting existing data for the first record in the input file

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME_MI}" in local folder "${testdata.path}/testdata" and assign to variables:
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

    And I extract below values for row 3 from PSV file "${INPUT_FILENAME_MI}" in local folder "${testdata.path}/testdata" and assign to variables:
      | CANCEL_IND | VAR_CANCEL_IND_CANC |

  Scenario Outline: TC_04: Intraday Cash File (Misc) Validations for input field: <ValidationStatus> :

    Then I expect value of column "<ValidationStatus>" in the below SQL query equals to "PASS":
    """
    <SQL>
    """
    Examples: Expecting 'Pass' for each field from New Cash File vs Database
      | ValidationStatus             | SQL                                                                                                                                                                                                                                                                                                                                                                                  |
      | INSTR_ID_CHECK               | SELECT CASE WHEN COUNT(INSTR_ID) =1 THEN 'PASS' ELSE 'FAIL' END AS INSTR_ID_CHECK FROM FT_T_ISID WHERE ISS_ID='${INSTR_ID1}' AND ID_CTXT_TYP='BNPLSTID' AND END_TMS IS NULL                                                                                                                                                                                                          |
      | ACCT_ID_CHECK                | SELECT CASE WHEN COUNT(ACCT_ID) =1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_ID_CHECK FROM FT_T_ACID WHERE ACCT_ALT_ID='${ACCT_ID1}' AND ACCT_ID_CTXT_TYP='BNPPRTID' AND END_TMS IS NULL                                                                                                                                                                                                   |
      | TRN_CDE_CHECK                | SELECT CASE WHEN COUNT(DISTINCT(R.TRN_CDE)) =1 THEN 'PASS' ELSE 'FAIL' END AS TRN_CDE_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.TRN_CDE LIKE 'BNPCASHTXN'                                                                                                                                  |
      | EXEC_TRN_CAT_SUB_TYP_CHECK   | SELECT CASE WHEN COUNT(DISTINCT(R.EXEC_TRN_CAT_SUB_TYP)) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_SUB_TYP_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.EXEC_TRN_CAT_SUB_TYP LIKE 'AUDITF'                                                                                               |
      | EXEC_TRN_CAT_TYP_CHECK       | SELECT CASE WHEN COUNT(DISTINCT(R.EXEC_TRN_CAT_TYP)) =1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK FROM FT_T_EXTR R JOIN FT_T_ISID S ON R.INSTR_ID = S.INSTR_ID WHERE S.ISS_ID='${INSTR_ID1}' AND S.ID_CTXT_TYP='BNPLSTID' AND R.EXEC_TRN_CAT_TYP LIKE 'MISC'                                                                                                             |
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
