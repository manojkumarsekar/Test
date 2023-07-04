SELECT *
    FROM   (
             SELECT o.pref_order_id, a.acct_alt_id acct_crts_id, b.iss_id instr_bcusip, replace(i.pref_iss_nme,'&','&'||'amp;') instr_name
             FROM   (
                      SELECT pref_order_id, acct_org_id, acct_bk_id, acct_id
                      FROM   ft_t_auor
                      WHERE  acct_id IS NOT NULL
                      AND    NVL(data_stat_typ, 'ACTIVE') = 'ACTIVE'
                      GROUP BY pref_order_id, acct_org_id, acct_bk_id, acct_id
                      HAVING COUNT(*) > 1
                    ) x,
                    ft_t_auor o,
                    ft_t_acid a,
                    ft_t_issu i,
                    ft_t_isid b
             WHERE  o.pref_order_id = x.pref_order_id
             AND    a.org_id = x.acct_org_id
             AND    a.bk_id = x.acct_bk_id
             AND    a.acct_id = x.acct_id
             AND    a.acct_id_ctxt_typ = 'CRTSID'
             AND    i.instr_id = o.instr_id
             AND    i.iss_typ = 'EQSHR'
             AND    b.instr_id = i.instr_id
             AND    a.end_tms is null
             AND    i.end_tms is null
             AND    b.end_tms is null
             AND    b.id_ctxt_typ = 'BCUSIP'
             ORDER BY o.last_chg_tms DESC
           )
    WHERE ROWNUM = 1