delete ft_T_exst where exec_trd_id in (select exec_trd_id from ft_T_extr where  TRD_ID in ('3204-302','3204-2776_valid_trade_parent','3204-401a_AT','3204-402a_AT','3204-403a_AT','3204-ZZXX','3204-TR02') and end_tms is null) and data_Src_id='SSB';
UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3204-302','3204-2776_valid_trade_parent','3204-401a_AT','3204-402a_AT','3204-403a_AT','3204-ZZXX','3204-TR02') AND END_TMS IS NULL;
UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3204-302','3204-2776_valid_trade_parent','3204-401a_AT','3204-402a_AT','3204-403a_AT','3204-ZZXX','3204-TR02') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
UPDATE ft_t_acgp
    SET
        end_tms = SYSDATE
WHERE
    acct_id IN (
        SELECT
            acct_id
        FROM
            ft_t_acid
        WHERE
            acct_id_ctxt_typ = 'CRTSID'
            AND   acct_alt_id = 'Test3383'
            AND   end_tms IS NULL
    )
    AND   prnt_acct_grp_oid IN (
        SELECT
            acct_grp_oid
        FROM
            ft_t_acgr
        WHERE
            grp_nme IN (
                'TWFACAP1',
                'TWFACAP2',
                'TWFACAP3'
            )
            AND   grp_purp_typ = 'UNIVERSE'
            AND   acct_grp_id IN (
                'TWFACAP1',
                'TWFACAP2',
                'TWFACAP3'
            )
    )
    AND   end_tms IS NULL;
Commit;