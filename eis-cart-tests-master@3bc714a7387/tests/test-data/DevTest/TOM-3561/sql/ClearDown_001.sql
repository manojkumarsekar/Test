-- remove "NDCRMF", "ATPTWM" (GS0000000802, GS0000000776) from the UK-life list
DELETE ft_t_acgp
WHERE acgp_oid IN
(
    SELECT acgp.acgp_oid
    FROM ft_t_acgp acgp
        JOIN ft_t_acid acid
            ON acgp.acct_org_id = acid.org_id
            AND acgp.acct_bk_id = acid.bk_id
            AND acgp.acct_id = acid.acct_id
            AND acgp.end_tms IS NULL
            AND acid.end_tms IS NULL
            AND acid.acct_id_ctxt_typ = 'HIPORTID'
            AND acid.acct_alt_id IN ('NDCRMF', 'ATPTWM') -- GS0000000802, GS0000000776
    WHERE acgp.prnt_acct_grp_oid =
    (
        SELECT acct_grp_oid
        FROM ft_t_acgr
        WHERE acct_grp_id = 'SGLUKLNP'
        AND end_tms IS NULL
    )
);

COMMIT;