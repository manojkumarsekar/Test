INSERT INTO
    ft_t_acgp
SELECT
    (
        select acct_grp_oid
        from   ft_t_acgr
        where  acct_grp_id = 'GRP_ISS_SEC_DEBT'
            and end_tms is null
    ),
    SYSDATE,
    NULL,
    'EIS ',
    'EIS ',
    acct_id,
    NULL,
    NULL,
    NULL,
    'MEMBER',
    SYSDATE,
    'EISDEV-6711',
    NULL,
    '',
    'ACTIVE',
    'EIS',
    NULL,
    NULL,
    new_oid()
FROM
    ft_t_acid acid
WHERE
    acct_id_ctxt_typ = 'CRTSID'
    AND end_tms IS NULL
    and acct_alt_id in (
    'ALAHYB','ALAIGB','ALALBF','ALAREB','ALASBF','ALATRF','ALESGB','ALGEMB','ALGMHY','ALCBDF'
    )
    and NOT EXISTS (
        SELECT
            1
        FROM
            ft_t_acgp
        WHERE
            acct_id = acid.acct_id
            AND prnt_acct_grp_oid = (
                select
                    acct_grp_oid
                from
                    ft_t_acgr
                where
                    acct_grp_id = 'GRP_ISS_SEC_DEBT'
                    and end_tms is null
            )
    );

COMMIT;