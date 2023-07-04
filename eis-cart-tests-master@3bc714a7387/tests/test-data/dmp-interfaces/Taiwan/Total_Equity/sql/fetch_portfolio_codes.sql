SELECT p1.acct_alt_id PORTFOLIO_CRTS_1,
       p2.acct_alt_id PORTFOLIO_CRTS_2
FROM   (SELECT Min(acct_id) p1_id,
               Max(acct_id) p2_id
        FROM   (SELECT ACID.acct_id
                FROM   ft_cfg_vrt1 VRT1,
                       ft_t_acgr ACGR,
                       ft_t_acgp ACGP,
                       ft_t_acid ACID
                WHERE  VRT1.vnd_rqst_typ = 'EIS_FundamentalsTE'
                       AND VRT1.acct_grp_oid = ACGR.acct_grp_oid
                       AND ACGR.acct_grp_oid = ACGP.prnt_acct_grp_oid
                       AND ACGP.acct_id = ACID.acct_id
                       AND ACID.acct_id_ctxt_typ = 'CRTSID'
                       AND ACID.end_tms IS NULL
                       AND ACGR.end_tms IS NULL
                       AND ACGP.end_tms IS NULL
                       AND VRT1 .end_tms IS NULL
                       AND rownum < 3)) x,
       ft_t_acid p1,
       ft_t_acid p2
WHERE  p1.acct_id = x.p1_id
       AND p1.acct_id_ctxt_typ = 'CRTSID'
       AND p1.end_tms IS NULL
       AND p2.acct_id = x.p2_id
       AND p2.acct_id_ctxt_typ = 'CRTSID'
       AND p2.end_tms IS NULL