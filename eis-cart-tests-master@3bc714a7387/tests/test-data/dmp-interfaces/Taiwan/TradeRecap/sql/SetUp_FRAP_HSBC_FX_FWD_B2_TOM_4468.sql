INSERT INTO ft_t_acgp (
    prnt_acct_grp_oid,
    start_tms,
    acct_grp_oid,
    acct_org_id,
    acct_bk_id,
    acct_id,
    end_tms,
    part_rank_num,
    part_typ,
    prt_purp_typ,
    last_chg_tms,
    last_chg_usr_id,
    curr_cde,
    prt_desc,
    data_stat_typ,
    data_src_id,
    part_camt,
    part_cpct,
    acgp_oid
)
    SELECT
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE  grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP2'
        ),
        SYSDATE,
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP2'
        ),
        'EIS',
        'EIS',
        acct_id,
        NULL,
        NULL,
        NULL,
        'MEMBER',
        SYSDATE,
        '4468_ACGP_TEST',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        new_oid
    FROM
        ft_t_acid acid
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id IN ('TSTTT56','TSTTT56_S','TSTTT56_TWD','TSTTT16','TSTTT16_TWD')
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acgp acgp
            WHERE
                prnt_acct_grp_oid = (
                    SELECT
                        acct_grp_oid
                    FROM
                        ft_t_acgr
                    WHERE
                        grp_nme = 'TWFACAP2'
                        AND   grp_purp_typ = 'UNIVERSE'
                        AND   acct_grp_id = 'TWFACAP2'
                )
                AND   acid.acct_id = acgp.acct_id
        );

INSERT INTO ft_t_frap (
    frap_oid,
    inst_mnem,
    finsrl_typ,
    org_id,
    bk_id,
    acct_id,
    prt_purp_typ,
    start_tms,
    end_tms,
    last_chg_tms,
    last_chg_usr_id,
    part_curr_cde,
    prt_desc,
    data_stat_typ,
    data_src_id,
    part_camt,
    part_cpct,
    prim_rel_ind,
    rel_stat_typ,
    rel_stat_tms,
    finsrl_acct_id,
    fins_inst_mnem,
    claimable_ind,
    rel_approved_ind,
    rel_approved_tms,
    participant_id
)
    SELECT
        NEW_OID,
        'lq6O01>I81',
        'FUNDADM',
        'EIS',
        'EIS',
        acct_id,
        NULL,
        SYSDATE,
        NULL,
        SYSDATE,
        '4468_FRAP_TEST',
        NULL,
        NULL,
        'ACTIVE',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM
        ft_t_acid acid
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id IN ('TSTTT56','TSTTT56_S','TSTTT56_TWD','TSTTT16','TSTTT16_TWD')
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_frap frap
            WHERE
                frap.inst_mnem = 'lq6O01>I81'
                AND   frap.finsrl_typ = 'FUNDADM'
                AND   acid.acct_id = frap.acct_id
        );


COMMIT;