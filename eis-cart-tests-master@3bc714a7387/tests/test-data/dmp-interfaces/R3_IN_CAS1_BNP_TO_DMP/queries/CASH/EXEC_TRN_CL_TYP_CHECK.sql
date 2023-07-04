SELECT EXEC_TRN_CL_TYP,CASE WHEN EXEC_TRN_CL_TYP = '${VAR_BNP_CASH_IMPACT_CODE}' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CL_TYP_CHECK
FROM FT_T_EXTR
WHERE EXEC_TRD_ID =
(
    SELECT EXEC_TRD_ID FROM FT_T_ETID
    WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}' AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
)