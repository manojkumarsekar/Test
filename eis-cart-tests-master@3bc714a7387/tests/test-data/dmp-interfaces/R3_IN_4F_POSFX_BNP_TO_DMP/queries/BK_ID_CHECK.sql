SELECT CASE WHEN BK_ID=(
                            SELECT BK_ID FROM FT_T_ACID
                            WHERE ACCT_ID_CTXT_TYP='BNPPRTID'
                            AND ACCT_ALT_ID='${VAR_ACCT_ID}'
                         )
                         THEN 'PASS' ELSE 'FAIL' END AS BK_ID_CHECK
FROM FT_T_BALH
WHERE BALH_OID='${BALH_OID}'