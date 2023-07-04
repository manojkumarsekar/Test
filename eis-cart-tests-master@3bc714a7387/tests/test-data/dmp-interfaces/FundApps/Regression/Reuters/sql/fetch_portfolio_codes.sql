SELECT p1.acct_alt_id PORTFOLIO_CRTS_1,
       p2.acct_alt_id PORTFOLIO_CRTS_2
FROM   (
         SELECT MIN(acct_id) p1_id, 
                MAX(acct_id) p2_id
         FROM   (
                  select acct_id from ft_t_acid acid where acct_id_ctxt_typ = 'CRTSID' and end_tms is null and ACCT_ALT_ID = upper(ACCT_ALT_ID)
                  and exists (select acct_id from ft_t_acst where stat_def_id = 'SSHFLAG' and end_tms is null and acid.acct_id = acct_id)
                ) 
       ) x,
       ft_t_acid p1,
       ft_t_acid p2
WHERE  p1.acct_id = x.p1_id
AND    p1.acct_id_ctxt_typ = 'CRTSID'
AND    p1.end_tms IS NULL
AND    p2.acct_id = x.p2_id
AND    p2.acct_id_ctxt_typ = 'CRTSID'
AND    p2.end_tms IS NULL