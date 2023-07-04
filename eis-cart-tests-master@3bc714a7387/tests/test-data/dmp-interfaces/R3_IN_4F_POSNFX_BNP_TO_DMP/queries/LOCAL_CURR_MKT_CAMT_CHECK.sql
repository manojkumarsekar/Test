SELECT CASE WHEN
(CASE WHEN LOCAL_CURR_MKT_CAMT IS NULL THEN 0 ELSE LOCAL_CURR_MKT_CAMT END)=
(CASE WHEN ${VAR_ACCRUED_INC_L} IS NULL THEN (CASE WHEN ${VAR_VALUATION_L} IS NULL THEN 0 ELSE ${VAR_VALUATION_L} END)
ELSE (CASE WHEN ${VAR_VALUATION_L} IS NULL THEN 0 ELSE ${VAR_VALUATION_L} END) - ${VAR_ACCRUED_INC_L} END)
THEN 'PASS' ELSE 'FAIL' END AS LOCAL_CURR_MKT_CAMT_CHECK,LOCAL_CURR_MKT_CAMT AS ACTUAL
FROM FT_T_BALH
WHERE BALH_OID='${BALH_OID}'