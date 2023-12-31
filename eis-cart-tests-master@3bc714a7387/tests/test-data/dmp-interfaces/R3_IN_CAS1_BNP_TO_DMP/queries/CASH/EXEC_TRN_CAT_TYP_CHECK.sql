SELECT CASE
WHEN '${INPUT_FILENAME}' LIKE '%MISC%'
THEN
(
    SELECT CASE WHEN EXEC_TRN_CAT_TYP ='MISC' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRD_ID =
    (
        SELECT EXEC_TRD_ID FROM FT_T_ETID
        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}' AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
    )
)
WHEN '${INPUT_FILENAME}' LIKE '%NEWCASH%'
THEN
(
    SELECT CASE WHEN EXEC_TRN_CAT_TYP ='NEW CASH' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRD_ID =
    (
        SELECT EXEC_TRD_ID FROM FT_T_ETID
        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}' AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
    )
)
WHEN '${INPUT_FILENAME}' LIKE '%_COLL_MM%'
THEN
(
    SELECT CASE WHEN EXEC_TRN_CAT_TYP ='COLLAT/MARGIN' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRD_ID =
    (
        SELECT EXEC_TRD_ID FROM FT_T_ETID
        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}' AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
    )
)
WHEN '${INPUT_FILENAME}' LIKE '%FX%'
THEN
(
    SELECT CASE WHEN EXEC_TRN_CAT_TYP ='FX' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK
    FROM FT_T_EXTR
    WHERE EXEC_TRD_ID =
    (
        SELECT EXEC_TRD_ID FROM FT_T_ETID
        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}' AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
    )
)
END AS EXEC_TRN_CAT_TYP_CHECK,'${INPUT_FILENAME}' AS FILE_PROCESSED FROM DUAL