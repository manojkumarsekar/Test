UPDATE FT_T_ACCR SET END_TMS = SYSDATE WHERE ACCT_ID IN
(select ACCT_ID from ft_T_EXTR where trd_id in ('4694-4762','4694-4722','4694-4716_5048_FUTUREANY','4694-4716_Cust','4694-302','4694-4694_valid_trade_parent','4694-401a_AT','4694-402a_AT','4694-403a_AT')
AND END_TMS IS NULL) and ORG_ID = 'EIS' and BK_ID = 'EIS' and end_tms is null;
delete ft_T_exst where exec_trd_id in (select exec_trd_id from ft_T_extr where  TRD_ID in ('4694-4762','4694-4722','4694-4716_5048_FUTUREANY','4694-4716_Cust','4694-302','4694-4694_valid_trade_parent','4694-401a_AT','4694-402a_AT','4694-403a_AT') and end_tms is null) and data_Src_id='SSB';
UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('4694-4762','4694-4722','4694-4716_5048_FUTUREANY','4694-4716_Cust','4694-302','4694-4694_valid_trade_parent','4694-401a_AT','4694-402a_AT','4694-403a_AT') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('4694-4762','4694-4722','4694-4716_5048_FUTUREANY','4694-4716_Cust','4694-302','4694-4694_valid_trade_parent','4694-401a_AT','4694-402a_AT','4694-403a_AT') AND END_TMS IS NULL;
UPDATE FT_T_ACID SET END_TMS = SYSDATE WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID in ( 'TW-MAIN-SITCA-1-SSB') and end_tms is null);
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
            AND   acct_alt_id = 'Test4694'
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