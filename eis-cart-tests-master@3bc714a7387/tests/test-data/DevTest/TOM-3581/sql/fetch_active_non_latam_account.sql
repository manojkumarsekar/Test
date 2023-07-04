SELECT i.acct_alt_id portfolio_code, a.acct_nme portfolio_name
FROM   ft_t_acct a,
       ft_t_acid i,
       (
         SELECT MAX(b.acct_id) acct_id
         FROM   ft_t_acgu g,
                ft_t_acid b,
                ft_t_fnch f
         WHERE  g.acct_id = b.acct_id 
         AND    g.end_tms IS NULL 
         AND    b.end_tms IS NULL 
         AND    g.gu_typ = 'REGION' 
         AND    g.gu_cnt = 1 
         AND    g.acct_gu_purp_typ = 'POS_SEGR' 
         AND    TRIM(g.gu_id) != 'LATAM' 
         AND    b.acct_id_ctxt_typ ='BNPPRTID'
         AND    f.acct_id = g.acct_id
         AND    f.fund_curr_cde = 'HKD'
       ) x
WHERE  x.acct_id = a.acct_id
AND    x.acct_id = i.acct_id
AND    i.acct_id_ctxt_typ = 'BNPPRTID'
AND    i.end_tms IS NULL