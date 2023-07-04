SELECT COUNT (*) AS VERIFY_EXECTRD
FROM FT_T_EXTR
    WHERE TRD_ID='${TRD_ID}'
    AND TRN_CDE='${TRN_CDE}'
    AND TRD_DTE = TO_DATE('${TRD_DTE}','DD/MM/YYYY')
    AND TRD_CURR_CDE='${TRD_CUR_CDE}'
    AND TRD_CQTY='${TRD_CQT}'
    AND TRD_CPRC='${TRD_PRZ}'
    AND TRN_SUB_TYP='${TRN_SUB_TYP}'
    AND INSTR_ID IN
                    (
                        SELECT INSTR_ID
                        FROM FT_T_ISID
                        WHERE ISS_ID='${SECURITY_ID}'
                        AND END_TMS IS NULL
                        AND ID_CTXT_TYP IN ('ISIN','SEDOL','CUSIP','${ID_CTXT_TYPE}')
                    )
    AND  ACCT_ID IN
                     (
                         SELECT ACCT_ID
                         FROM FT_T_ACID
                         WHERE ACCT_ALT_ID='${FUND_ID}'
                         AND END_TMS IS NULL
                     )