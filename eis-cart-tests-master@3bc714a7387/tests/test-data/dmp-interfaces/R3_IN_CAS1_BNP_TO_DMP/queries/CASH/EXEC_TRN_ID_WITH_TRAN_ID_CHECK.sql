WITH TABL_1 AS
    (
        SELECT COUNT(*) RESULT FROM FT_T_ETID
        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_ID}' AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
    )
    SELECT CASE WHEN RESULT=1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_ID_WITH_TRAN_ID_CHECK,RESULT FROM TABL_1