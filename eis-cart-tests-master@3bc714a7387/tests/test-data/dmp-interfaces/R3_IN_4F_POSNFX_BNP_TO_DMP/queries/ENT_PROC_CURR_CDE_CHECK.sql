SELECT CASE WHEN ENT_PROC_CURR_CDE='${VAR_PFOLIO_CCY}' THEN 'PASS' ELSE 'FAIL' END AS ENT_PROC_CURR_CDE_CHECK,ENT_PROC_CURR_CDE AS EXPECTED,'${VAR_PFOLIO_CCY}' AS ACTUAL
FROM FT_T_BALH
WHERE BALH_OID='${BALH_OID}'
