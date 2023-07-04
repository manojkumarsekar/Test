-- ACGP: SSDR Exclusion Portfolios for PROD publishing
INSERT INTO ft_t_acgp
(
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
        SELECT acct_grp_oid
        FROM ft_t_acgr
        WHERE acct_grp_id = 'SSDRPRDEXCLPORT'
        AND org_id IS NULL
        AND subdiv_id IS NULL
        AND subd_org_id IS NULL
    ) AS prnt_acct_grp_oid,
    sysdate AS start_tms,
    NULL AS acct_grp_oid,
    acid.org_id AS acct_org_id,
    acid.bk_id AS acct_bk_id,
    acid.acct_id AS acct_id,
    NULL AS end_tms,
    NULL AS part_rank_num,
    NULL AS part_typ,
    'MEMBER' AS prt_purp_typ,
    sysdate AS last_chg_tms,
    'EIS:CTM (TOM-3630)' AS last_chg_usr_id,
    NULL AS curr_cde,
    'SSDR Production Excluded Portfolios' AS prt_desc,
    'ACTIVE' AS data_stat_typ,
    acid.data_src_id AS data_src_id,
    NULL AS part_camt,
    NULL AS part_cpct,
    new_oid() AS acgp_oid
FROM ft_t_acid acid
WHERE acct_alt_id = 'ALATRF'
AND acct_id_ctxt_typ = 'CRTSID'
AND end_tms IS NULL
AND NOT EXISTS
(
    SELECT 1
    FROM ft_t_acgp acgp
    WHERE acgp.prnt_acct_grp_oid =
    (
        SELECT acct_grp_oid
        FROM ft_t_acgr
        WHERE acct_grp_id = 'SSDRPRDEXCLPORT'
        AND org_id IS NULL
        AND subdiv_id IS NULL
        AND subd_org_id IS NULL
        AND end_tms IS NULL
    )
    AND acgp.acct_org_id = acid.org_id
    AND acgp.acct_bk_id = acid.bk_id
    AND acgp.acct_id = acid.acct_id
    AND acgp.prt_purp_typ = 'MEMBER'
    AND acgp.acct_grp_oid IS NULL
    AND acgp.end_tms IS NULL
);

COMMIT;