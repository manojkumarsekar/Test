INSERT INTO ft_t_acgp (prnt_acct_grp_oid, start_tms, acct_org_id, acct_bk_id, acct_id, prt_purp_typ, last_chg_tms, last_chg_usr_id, data_stat_typ, data_src_id, acgp_oid)
SELECT 'GRREQREP11', SYSDATE, acid.org_id, acid.bk_id, acid.acct_id, 'MEMBER', SYSDATE, 'TST:3374', 'ACTIVE', 'EIS', NEW_OID
FROM   ft_t_acid acid
WHERE  acid.acct_id_ctxt_typ = 'CRTSID'
AND    acid.end_tms IS NULL
AND    acid.acct_alt_id IN ('${PORTFOLIO_CRTS_1}','${PORTFOLIO_CRTS_2}')
AND    NOT EXISTS (SELECT 1 FROM ft_t_acgp acgp WHERE acgp.prnt_acct_grp_oid = 'GRREQREP11' AND acgp.end_tms IS NULL AND acgp.acct_org_id = acid.org_id AND acgp.acct_bk_id = acid.bk_id AND acgp.acct_id = acid.acct_id)