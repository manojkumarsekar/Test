SELECT
    COUNT(*) AS RECORD_COUNT
FROM
    ft_t_aopt
WHERE
    auor_oid IN (
        SELECT
            auor_oid
        FROM
            ft_t_auor
        WHERE
            pref_order_id = 'TST1725736'
            AND   acct_id IS NULL
    )
    AND   order_part_rl_typ = 'Dealer'
    AND   fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpid
        WHERE
            fins_pro_id = 'P9SASWAT'
            AND   fins_pro_id_ctxt_typ = 'BRS_INITIALS'
    )
    OR    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpid
        WHERE
            fins_pro_id = 'P9SASWAT'
            AND   fins_pro_id_ctxt_typ = 'BRS_LOGIN'
    )