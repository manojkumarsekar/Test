INSERT INTO gs_gc.ft_t_acct (org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, actp_org_id, actp_acct_typ, acct_nme, acct_desc, data_stat_typ, data_src_id, acct_purp_typ)
SELECT  'EIS', 'EIS','GS0000003606', SYSDATE, 'OPEN', 'm1n)m>g<G1', SYSDATE, 'TOM-3488 (MOCK)','EIS','FUND','EASTSPRING INV US MULTI-FACTOR EQUITY FUND','EASTSPRING INV US MULTI-FACTOR EQUITY FUND','ACTIVE','BRS','RETAIL'
FROM dual WHERE NOT EXISTS ( SELECT 1 FROM gs_gc.ft_t_acct  WHERE acct_id = 'GS0000003606' AND org_id = 'EIS' AND bk_id = 'EIS' );

INSERT INTO gs_gc.ft_t_acct (org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, actp_org_id, actp_acct_typ, acct_nme, acct_desc, data_stat_typ, data_src_id, acct_purp_typ)
SELECT 'EIS', 'EIS', 'GS0000003705', SYSDATE,'OPEN','bJ7V41saO1',SYSDATE,'TOM-3488 (MOCK)','EIS','FUND','IMDA SG BONDS','IMDA SG BONDS','ACTIVE','BRS','INSTI'
FROM dual WHERE NOT EXISTS ( SELECT * FROM gs_gc.ft_t_acct WHERE acct_id = 'GS0000003705' AND org_id = 'EIS' AND bk_id = 'EIS');

INSERT INTO gs_gc.ft_t_acct (org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, actp_org_id, actp_acct_typ, acct_nme, acct_desc, data_stat_typ, data_src_id, acct_purp_typ)
SELECT 'EIS','EIS','GS0000003805',SYSDATE,'OPEN','bJ7r41saO1',SYSDATE,'TOM-3488 (MOCK)','EIS','FUND','UBZF','UBZF','ACTIVE','BRS','INSTI'
FROM dual WHERE NOT EXISTS ( SELECT 1 FROM gs_gc.ft_t_acct WHERE acct_id = 'GS0000003805' AND org_id = 'EIS' AND bk_id = 'EIS');

INSERT INTO gs_gc.ft_t_acct (org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, actp_org_id, actp_acct_typ, acct_nme, acct_desc, data_stat_typ, data_src_id, acct_purp_typ)
SELECT  'EIS','EIS','GS0000004106',SYSDATE,'PENDOPEN','bL7S31saO1',SYSDATE,'TOM-3488 (MOCK)','EIS','FUND','PHKL SHAREHOLDER BUSINESS INVESTMENT FUND C','PHKL SHAREHOLDER BUSINESS INVESTMENT FUND C','ACTIVE',NULL,'NON PAR'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acct WHERE acct_id = 'GS0000004106' AND org_id = 'EIS' AND bk_id = 'EIS');

INSERT INTO gs_gc.ft_t_acct (org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, actp_org_id, actp_acct_typ, acct_nme, acct_desc, data_stat_typ, data_src_id, acct_purp_typ)
SELECT 'EIS','EIS','GS0000004107',SYSDATE,'PENDOPEN','bL7U31saO1',SYSDATE,'TOM-3488 (MOCK)','EIS','FUND','PHKL SHAREHOLDER BUSINESS INVESTMENT FUND D','PHKL SHAREHOLDER BUSINESS INVESTMENT FUND D','ACTIVE', NULL,'NON PAR'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acct WHERE acct_id = 'GS0000004107' AND org_id = 'EIS' AND bk_id = 'EIS');

-- Insert ACID values for new portfolios

INSERT INTO gs_gc.ft_t_acid ( acid_oid, org_id, bk_id,acct_id,acct_id_ctxt_typ,acct_alt_id, start_tms,last_chg_tms,last_chg_usr_id,data_stat_typ,acct_cross_ref_id)
SELECT new_oid(),'EIS','EIS','GS0000003606','CRTSID','ALGUMF',SYSDATE,SYSDATE,'TOM-3488 (MOCK)','ACTIVE','m1n)m>g<G1'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acid WHERE acct_id = 'GS0000003606' AND org_id = 'EIS' AND bk_id = 'EIS' AND acct_id_ctxt_typ = 'CRTSID' AND end_tms IS NULL);

INSERT INTO gs_gc.ft_t_acid ( acid_oid, org_id, bk_id,acct_id,acct_id_ctxt_typ,acct_alt_id, start_tms,last_chg_tms,last_chg_usr_id,data_stat_typ,acct_cross_ref_id)
SELECT new_oid(),'EIS','EIS','GS0000003705','CRTSID','18STAR',SYSDATE,SYSDATE,'TOM-3488 (MOCK)','ACTIVE','bJ7V41saO1'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acid WHERE acct_id = 'GS0000003705' AND org_id = 'EIS' AND bk_id = 'EIS' AND acct_id_ctxt_typ = 'CRTSID' AND end_tms IS NULL);

INSERT INTO gs_gc.ft_t_acid ( acid_oid, org_id, bk_id,acct_id,acct_id_ctxt_typ,acct_alt_id, start_tms,last_chg_tms,last_chg_usr_id,data_stat_typ,acct_cross_ref_id)
SELECT new_oid(),'EIS','EIS','GS0000003805','CRTSID','UBZF',SYSDATE,SYSDATE,'TOM-3488 (MOCK)','ACTIVE','bJ7r41saO1'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acid WHERE acct_id = 'GS0000003805' AND org_id = 'EIS' AND bk_id = 'EIS' AND acct_id_ctxt_typ = 'CRTSID' AND end_tms IS NULL);

INSERT INTO gs_gc.ft_t_acid ( acid_oid, org_id, bk_id,acct_id,acct_id_ctxt_typ,acct_alt_id, start_tms,last_chg_tms,last_chg_usr_id,data_stat_typ,acct_cross_ref_id)
SELECT new_oid(),'EIS','EIS','GS0000004106','CRTSID','AHPSHC',SYSDATE,SYSDATE,'TOM-3488 (MOCK)','ACTIVE','bL7S31saO1'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acid WHERE acct_id = 'GS0000004106' AND org_id = 'EIS' AND bk_id = 'EIS' AND acct_id_ctxt_typ = 'CRTSID' AND end_tms IS NULL);

INSERT INTO gs_gc.ft_t_acid ( acid_oid, org_id, bk_id,acct_id,acct_id_ctxt_typ,acct_alt_id, start_tms,last_chg_tms,last_chg_usr_id,data_stat_typ,acct_cross_ref_id)
SELECT new_oid(),'EIS','EIS','GS0000004107','CRTSID','AHPSHD',SYSDATE,SYSDATE,'TOM-3488 (MOCK)','ACTIVE','bL7U31saO1'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM gs_gc.ft_t_acid WHERE acct_id = 'GS0000004107' AND org_id = 'EIS' AND bk_id = 'EIS' AND acct_id_ctxt_typ = 'CRTSID' AND end_tms IS NULL);

COMMIT;