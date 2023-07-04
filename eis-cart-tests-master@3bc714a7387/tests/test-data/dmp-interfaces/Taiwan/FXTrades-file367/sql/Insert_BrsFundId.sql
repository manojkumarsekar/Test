INSERT INTO ft_t_acid (
    acid_oid,
    org_id,
    bk_id,
    acct_id,
    entr_org_id,
    subd_org_id,
    subdiv_id,
    acct_id_ctxt_typ,
    acct_alt_id,
    start_tms,
    end_tms,
    last_chg_tms,
    last_chg_usr_id,
    data_stat_typ,
    data_src_id,
    acct_cross_ref_id,
    acct_id_stat_typ,
    acct_id_stat_tms
)
    SELECT
        NEW_OID,
        'EIS',
        'EIS',
        acct_id,
        NULL,
        NULL,
        NULL,
        'BRSFUNDID',
        '3497',
        SYSDATE,
        NULL,
        SYSDATE,
        '3382_ACID_TEST',
        NULL,
        'BRS',
        acct_cross_ref_id,
        NULL,
        NULL
    FROM
        ft_t_acid acid1
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id = '${SHARE_PORTFOLIO_NAME}'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acid acid2
            WHERE
                acid2.acct_id_ctxt_typ = 'BRSFUNDID'
                AND   acid2.acct_alt_id = '3497'
                AND   acid1.acct_id = acid2.acct_id
        );
 COMMIT;