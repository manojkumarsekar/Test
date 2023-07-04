SELECT CASE WHEN (CASE WHEN HST_REAS_TYP IS NULL THEN ' ' ELSE HST_REAS_TYP END)=
(CASE WHEN '${VAR_BALANCE_TYPE}' ='null' THEN ' ' ELSE '${VAR_BALANCE_TYPE}' END) THEN 'PASS' ELSE 'FAIL' END AS HST_REAS_TYP_CHECK, HST_REAS_TYP AS ACTUAL,'${VAR_BALANCE_TYPE}' AS EXPECTED
FROM FT_T_BALH
WHERE BALH_OID='${BALH_OID}'
