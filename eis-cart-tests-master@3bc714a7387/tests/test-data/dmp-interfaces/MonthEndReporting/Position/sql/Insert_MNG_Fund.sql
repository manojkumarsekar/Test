    INSERT INTO ft_t_cacr
            (cst_id,
             org_id,
             bk_id,
             acct_id,
             rl_typ,
             start_tms,
             last_chg_usr_id,
             last_chg_tms,
             data_stat_typ,
             cacr_oid)
SELECT (SELECT cst_id
        FROM   ft_t_cuid
        WHERE  UPPER(customer_id) = 'PRUDENTIAL ASSURANCE COMPANY LIMITED – UK LIFE'),
       'EIS',
       'EIS',
       acct_id,
       'CLIENT',
       sysdate,
       350295,
       sysdate,
       'ACTIVE',
       New_oid()
FROM   ft_t_acct
WHERE  acct_desc = 'SCOTTISH AMICABLE CAPITAL SUPPORT FUND (SACF) - ASIAN EQUITY SUB-FUND (SACFA)'
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_acct acct
                              INNER JOIN ft_t_cacr cacr
                                      ON cacr.acct_id = acct.acct_id
                              INNER JOIN ft_t_cuid cuid
                                      ON cuid.cst_id = cacr.cst_id
                       WHERE  UPPER(cuid.customer_id) = 'PRUDENTIAL ASSURANCE COMPANY LIMITED – UK LIFE'
                              AND acct.acct_desc =
                                  'SCOTTISH AMICABLE CAPITAL SUPPORT FUND (SACF) - ASIAN EQUITY SUB-FUND (SACFA)')