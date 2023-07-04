SELECT
    COUNT(*) AS RECORD_COUNT
FROM
    ft_t_auor
WHERE
    pref_order_id = 'TST1725736'
    AND   acct_id IN (
        SELECT
            acct_id
        FROM
            ft_t_acid
        WHERE
            acct_alt_id IN (
                'ALINDF'
            )
    )