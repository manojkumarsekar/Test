SELECT CASE WHEN LOCAL_CURR_MKT_CAMT = -LOCAL_CURR_INC_ACCR_CAMT THEN 'PASS' ELSE 'FAIL' END AS LOCAL_CURR_MKT_CAMT_CHECK
FROM FT_T_BALH
WHERE BALH_OID='${BALH_OID}'