SELECT COUNT (1) AS ETRP_PROCESSED_ROW_COUNT
FROM FT_T_ETRP
WHERE REPO_CRTE = '2951236' AND   TO_CHAR (REPO_CLOSE_SETTLE_DTE, 'DD/MM/YY') = '26/11/18' AND   EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID
                                                                                                                FROM FT_T_EXTR
                                                                                                                WHERE TRD_ID = '3204-2776_valid_trade' AND   EXEC_TRN_CAT_TYP = 'TRD' AND   EXEC_TRN_CAT_SUB_TYP = 'I' AND   TO_CHAR (TRD_DTE, 'MM/DD/YYYY') = '11/20/2018' AND   TO_CHAR (INPUT_APPL_TMS, 'MM/DD/YYYY HH24:MI:SS') = '11/20/2018 00:24:11' AND   TO_CHAR (SETTLE_DTE, 'MM/DD/YYYY') = '11/26/2018'
AND   TRD_CURR_CDE = 'JPY' AND   TRD_CPRC = '1054.0075' AND   TRN_CDE = 'BRSEOD' AND   TRD_CQTY = '-35000.1' AND   END_TMS IS NULL
)