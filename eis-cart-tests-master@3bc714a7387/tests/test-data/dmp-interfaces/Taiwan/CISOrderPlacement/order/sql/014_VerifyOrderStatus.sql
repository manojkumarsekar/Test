SELECT Count(1) AS "NEWSENT_COUNT"
FROM   ft_t_auor auor,
       ft_t_aost aost
WHERE  pref_order_id IN ( '2452751B', '24527520B', '24527521B', '24527522B',
                          '24527523B', '24527524B', '24527525B', '24527526B',
                          '24527527B', '24527528B', '24527529B', '24527530B',
                          '24527532B', '24527533B', '24527534B', '24527536B',
                          '24527537B', '24527538B', '24527539B', '24527540B',
                          '24527541B', '24527542B', '24527543B', '24527544B',
                          '24527545B', '24527546B', '24527547B', '24527548B',
                          '24527549B', '24527550B' )
       AND pref_order_id_ctxt_typ = 'BRS_ORDER'
       AND acct_id IS NOT NULL
       AND auor.auor_oid = aost.auor_oid
       AND aost.order_stat_typ = 'NEWSENT'