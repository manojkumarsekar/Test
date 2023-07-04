SELECT
    COUNT(*) AS RECORD_COUNT
FROM
    ft_t_aocm
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
    AND   cmnt_reas_typ = 'BRSPMNOTE'