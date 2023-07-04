-- LATAM
INSERT INTO ft_t_acgu
(
    acgu_oid,
    org_id,
    bk_id,
    acct_id,
    gu_id,
    gu_typ,
    gu_cnt,
    acct_gu_purp_typ,
    start_tms,
    last_chg_tms,
    last_chg_usr_id,
    data_stat_typ,
    data_src_id
)
SELECT
    new_oid                 AS acgu_oid,
    acid.org_id             AS org_id,
    acid.bk_id              AS bk_id,
    acid.acct_id            AS acct_id,
    'LATAM'                 AS gu_id,
    'REGION'                AS gu_typ,
    '1'                     AS gu_cnt,
    'POS_SEGR'              AS acct_gu_purp_typ,
    sysdate                 AS start_tms,
    sysdate                 AS last_chg_tms,
    'EIS:CTM (TOM-3488)'    AS last_chg_usr_id,
    'ACTIVE'                AS data_stat_typ,
    'EIS'                   AS data_src_id
FROM ft_t_acid acid
WHERE acid.acct_id_ctxt_typ = 'CRTSID'
AND acid.end_tms IS NULL
AND acid.acct_alt_id IN
(
    'ALGUMF',
    'AHPSHC',
    'AHPSHD'
)
AND NOT EXISTS
(
    SELECT 1
    FROM ft_t_acgu acgu
    WHERE acgu.org_id = acid.org_id
    AND acgu.bk_id = acid.bk_id
    AND acgu.acct_id = acid.acct_id
    AND acgu.acct_gu_purp_typ = 'POS_SEGR'
	AND acgu.gu_id = 'LATAM'
    AND acgu.gu_typ = 'REGION'
    AND acgu.gu_cnt = 1
    AND acgu.end_tms IS NULL
	AND acid.acct_alt_id IN
	(
		'ALGUMF',
		'AHPSHC',
		'AHPSHD'
	)
);

-- NON-LATAM
INSERT INTO ft_t_acgu
(
    acgu_oid,
    org_id,
    bk_id,
    acct_id,
    gu_id,
    gu_typ,
    gu_cnt,
    acct_gu_purp_typ,
    start_tms,
    last_chg_tms,
    last_chg_usr_id,
    data_stat_typ,
    data_src_id
)
SELECT
    new_oid                 AS acgu_oid,
    acid.org_id             AS org_id,
    acid.bk_id              AS bk_id,
    acid.acct_id            AS acct_id,
    'NONLATAM'              AS gu_id,
    'REGION'                AS gu_typ,
    '1'                     AS gu_cnt,
    'POS_SEGR'              AS acct_gu_purp_typ,
    sysdate                 AS start_tms,
    sysdate                 AS last_chg_tms,
    'EIS:CTM (TOM-3488)'    AS last_chg_usr_id,
    'ACTIVE'                AS data_stat_typ,
    'EIS'                   AS data_src_id
FROM ft_t_acid acid
WHERE acid.acct_id_ctxt_typ = 'CRTSID'
AND acid.end_tms IS NULL
AND acid.acct_alt_id IN
(
    '18STAR',
    'UBZF'
 )
AND NOT EXISTS
(
    SELECT 1
    FROM ft_t_acgu acgu
    WHERE acgu.org_id = acid.org_id
    AND acgu.bk_id = acid.bk_id
    AND acgu.acct_id = acid.acct_id
    AND acgu.acct_gu_purp_typ = 'POS_SEGR'
	AND acgu.gu_id = 'NONLATAM'
    AND acgu.gu_typ = 'REGION'
    AND acgu.gu_cnt = 1
    AND acgu.end_tms IS NULL
	AND acid.acct_alt_id IN
	(
		'18STAR',
		'UBZF'
	 )
);

COMMIT;