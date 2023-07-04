--ACGP

INSERT INTO ft_t_acgp
    SELECT
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE
                acct_grp_id = 'TW_PROC'
        ),
        SYSDATE,
        NULL,
        'EIS ',
        'EIS ',
        (
            SELECT
                acct_id
            FROM
                ft_t_acid
            WHERE
                acct_alt_id = 'U_TT4298'
                AND   acct_id_ctxt_typ = 'CRTSID'
                AND   end_tms IS NULL
        ),
        NULL,
        NULL,
        NULL,
        'MEMBER  ',
        SYSDATE,
        '4298_TEST',
        NULL,
        '',
        'ACTIVE',
        'EIS',
        NULL,
        NULL,
        new_oid()
    FROM
        dual
    WHERE
        NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acgp
            WHERE
                acct_id IN (
                    SELECT
                        acct_id
                    FROM
                        ft_t_acid
                    WHERE
                        acct_alt_id = 'U_TT4298'
                        AND   acct_id_ctxt_typ = 'CRTSID'
                        AND   end_tms IS NULL
                )
                AND   prnt_acct_grp_oid = (
                    SELECT
                        acct_grp_oid
                    FROM
                        ft_t_acgr
                    WHERE
                        acct_grp_id = 'TW_PROC'
                )
        );

COMMIT;