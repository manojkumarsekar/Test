SELECT CASE WHEN DENOM_CURR_CDE='${VAR_ISSUE_CCY_L}' THEN 'PASS' ELSE 'FAIL' END AS DENOM_CURR_CDE_CHECK, DENOM_CURR_CDE AS ACTUAL,'${VAR_ISSUE_CCY_L}' AS EXPECTED
FROM FT_T_ISSU
WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${VAR_TRAN_ID}')
