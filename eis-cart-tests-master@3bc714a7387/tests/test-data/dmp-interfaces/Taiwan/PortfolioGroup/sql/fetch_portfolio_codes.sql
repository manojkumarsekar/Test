SELECT (SELECT acct_alt_id 
        FROM   (SELECT ROWNUM num, 
                       acct_alt_id 
                FROM   (SELECT acct_alt_id 
                        FROM   ft_t_acid 
                        WHERE  acct_id_ctxt_typ = 'BRSFUNDID' 
                               AND end_tms IS NULL 
                        ORDER  BY 1 DESC)) 
        WHERE  num = 1) PORTFOLIO_BRS_FUND_ID_1, 
       (SELECT acct_alt_id 
        FROM   (SELECT ROWNUM num, 
                       acct_alt_id 
                FROM   (SELECT acct_alt_id 
                        FROM   ft_t_acid 
                        WHERE  acct_id_ctxt_typ = 'BRSFUNDID' 
                               AND end_tms IS NULL 
                        ORDER  BY 1 DESC)) 
        WHERE  num = 2) PORTFOLIO_BRS_FUND_ID_2, 
       (SELECT acct_alt_id 
        FROM   (SELECT ROWNUM num, 
                       acct_alt_id 
                FROM   (SELECT acct_alt_id 
                        FROM   ft_t_acid 
                        WHERE  acct_id_ctxt_typ = 'BRSFUNDID' 
                               AND end_tms IS NULL 
                        ORDER  BY 1 DESC)) 
        WHERE  num = 3) PORTFOLIO_BRS_FUND_ID_3, 
       (SELECT acct_alt_id 
        FROM   (SELECT ROWNUM num, 
                       acct_alt_id 
                FROM   (SELECT acct_alt_id 
                        FROM   ft_t_acid 
                        WHERE  acct_id_ctxt_typ = 'BRSFUNDID' 
                               AND end_tms IS NULL 
                        ORDER  BY 1 DESC)) 
        WHERE  num = 4) PORTFOLIO_BRS_FUND_ID_4 
FROM   dual