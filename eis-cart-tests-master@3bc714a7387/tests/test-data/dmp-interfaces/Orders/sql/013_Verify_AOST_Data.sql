SELECT
    COUNT(*) AS RECORD_COUNT
FROM
    ft_t_aost
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
    AND   order_stat_typ = 'BOOKED'
    AND   gen_cnt = '2'
    AND   stat_tms = TO_DATE('12/03/2018 05:49:37','MM/DD/YYYY HH24:MI:SS')