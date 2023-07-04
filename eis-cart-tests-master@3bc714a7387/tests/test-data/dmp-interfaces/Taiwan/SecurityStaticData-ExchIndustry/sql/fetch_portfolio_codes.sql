SELECT p1.acct_alt_id PORTFOLIO_CRTS_1,
       p2.acct_alt_id PORTFOLIO_CRTS_2
FROM   (
         SELECT MIN(acct_id) p1_id, 
                MAX(acct_id) p2_id
         FROM   (
                  SELECT acct_id
                  FROM   ft_t_acid
                  WHERE  acct_alt_id LIKE 'TT__'
                  AND    acct_id_ctxt_typ = 'CRTSID'
                  AND    end_tms IS NULL
                  MINUS
                  SELECT acct_id
                  FROM   ft_t_balh
                  WHERE  as_of_tms = (SELECT MAX(as_of_tms) FROM ft_t_balh WHERE rqstr_id = 'BRSEOD')
                  AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370'))
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