SELECT CASE WHEN STAT_VAL_CAMT=${VAR_PRICE_L} THEN 'PASS' ELSE 'FAIL' END AS STAT_VAL_CAMT_CHECK,${VAR_PRICE_L} AS EXPECTED, STAT_VAL_CAMT AS ACTUAL
FROM FT_T_BHST
WHERE BALH_OID='${BALH_OID}'
AND STAT_DEF_ID ='PRICE'