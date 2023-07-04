INSERT INTO ft_t_acgr (
    acct_grp_oid,
    acct_grp_id,
    last_chg_tms,
    last_chg_usr_id,
    grp_purp_typ,
    start_tms,
    grp_nme,
    grp_desc,
    data_stat_typ,
    data_src_id
)
    SELECT
        NEW_OID,
        'TWFACAP2',
        SYSDATE,
        '4818_ACGP_TEST',
        'UNIVERSE',
        SYSDATE,
        'TWFACAP2',
        'Taiwan Fund Admin CAP 2',
        'ACTIVE',
        'EIS'
    FROM
        dual
    WHERE
        NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP2'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP2'
        );

INSERT INTO ft_t_acgr (
    acct_grp_oid,
    acct_grp_id,
    last_chg_tms,
    last_chg_usr_id,
    grp_purp_typ,
    start_tms,
    grp_nme,
    grp_desc,
    data_stat_typ,
    data_src_id
)
    SELECT
        NEW_OID,
        'TWFACAP3',
        SYSDATE,
        '4818_ACGP_TEST',
        'UNIVERSE',
        SYSDATE,
        'TWFACAP3',
        'Taiwan Fund Admin CAP 3',
        'ACTIVE',
        'EIS'
    FROM
        dual
    WHERE
        NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP3'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP3'
        );

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
            WHERE
                grp_nme = 'TWFACAP2'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP2'
        ),
        SYSDATE,
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP2'
                AND   grp_purp_typ = 'UNIVERSE'
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
        '4818_ACGP_TEST',
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
        AND   acct_alt_id = 'Test4818'
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
            WHERE
                grp_nme = 'TWFACAP3'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP3'
        ),
        SYSDATE,
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP3'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP3'
        ),
        'EIS',
        'EIS',
        acct_id,
        NULL,
        NULL,
        NULL,
        'MEMBER',
        SYSDATE,
        '4818_ACGP_TEST',
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
        AND   acct_alt_id = 'Test4818'
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
        '3382_FRAP_TEST',
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
        AND   acct_alt_id = 'Test4818'
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
        '4818',
        SYSDATE,
        NULL,
        SYSDATE,
        '4818_ACID_TEST',
        NULL,
        'BRS',
        'B55r112e81',
        NULL,
        NULL
    FROM
        ft_t_acid acid1
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id = 'Test4818'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acid acid2
            WHERE
                acid2.acct_id_ctxt_typ = 'BRSFUNDID'
                AND   acid2.acct_alt_id = '4818'
                AND   acid1.acct_id = acid2.acct_id
        );
COMMIT;