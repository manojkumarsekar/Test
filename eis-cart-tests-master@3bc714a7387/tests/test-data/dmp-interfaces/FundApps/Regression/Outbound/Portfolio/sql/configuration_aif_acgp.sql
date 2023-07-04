--EISDEV-7050: Create a account participants to validate this feature

INSERT INTO
    ft_t_acgp
SELECT
    (
        select acct_grp_oid
        from   ft_t_acgr
        where  acct_grp_id = 'FAAIF'
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
    'EISDEV-7050',
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
    'E35100'
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
                    acct_grp_id = 'FAAIF'
                    and end_tms is null
            )
    );
commit;