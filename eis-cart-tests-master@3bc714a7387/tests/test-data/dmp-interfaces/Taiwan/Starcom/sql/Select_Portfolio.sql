SELECT
      acid1.acct_alt_id PORTFOLIO_ID_1,
      acid2.acct_alt_id PORTFOLIO_ID_2
      FROM
      ft_t_acgr acgr,
      ft_t_acgp acgp,
      ft_t_acid acid1,
      ft_t_acid acid2
      WHERE
      acgr.acct_grp_oid = acgp.prnt_acct_grp_oid
      AND   acgr.acct_grp_id = 'ESI_TW_PROD'
      AND   acgr.end_tms IS NULL
      AND   acgr.grp_purp_typ = 'UNIVERSE'
      AND   acgp.end_tms IS NULL
      AND   acgp.prt_purp_typ = 'MEMBER'
      AND   acid1.acct_id = acgp.acct_id
      AND   acid1.end_tms IS NULL
      AND   acid2.end_tms IS NULL
      AND   acid1.acct_id_ctxt_typ = 'CRTSID'
      AND   acid2.acct_id_ctxt_typ = 'CRTSID'
      AND   acid1.acct_alt_id != acid2.acct_alt_id
      AND   acid1.acct_alt_id LIKE 'TT%'
      AND   acid2.acct_alt_id LIKE 'TT%'
      AND   ROWNUM = 1

