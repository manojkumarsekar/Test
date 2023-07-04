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
        '4694_ACGR_TEST',
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
        '4694_ACGR_TEST',
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
        '4694_ACGP_TEST',
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
        AND   acct_alt_id = 'Test4694'
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
                AND   acid.acct_id = acgp.acct_id AND acgp.end_tms is null
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
        '4694_ACGP_TEST',
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
        AND   acct_alt_id = 'Test4694'
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
        '4694',
        SYSDATE,
        NULL,
        SYSDATE,
        '4694_ACID_TEST',
        NULL,
        'BRS',
        acct_cross_ref_id,
        NULL,
        NULL
    FROM
        ft_t_acid acid1
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id = 'Test4694'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acid acid2
            WHERE
                acid2.acct_id_ctxt_typ = 'BRSFUNDID'
                AND   acid2.acct_alt_id = '4694'
                AND   acid1.acct_id = acid2.acct_id
        );
UPDATE ft_t_iscl
SET    cl_value = 'FUND',
       clsf_oid = (SELECT clsf_oid
                   FROM   ft_t_incl
                   WHERE  indus_cl_set_id = 'SECGROUP'
                          AND cl_value = 'FUND'
                          AND end_tms IS NULL)
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id = 'BPM1U4B12'
                           AND end_tms IS NULL)
       AND indus_cl_set_id = 'SECGROUP'
       AND cl_value <> 'FUND';

COMMIT;