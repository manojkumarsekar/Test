delete from ft_T_accv where acct_id  in (select acct_id from ft_T_accr where rep_acct_id  in (select acct_id from ft_T_acgp where prnt_acct_grp_oid  in (select acct_grp_oid from ft_t_acgr where acct_grp_id in ('TWFACAP1','TWFACAP2','TWFACAP3') and end_tms is null) and end_tms is null));

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TSTTT56_TWD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'DDR01' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56_TWD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TSTTT56_USD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'DDR02' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56_USD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TSTTT56_CNH', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'DDR03' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56_CNH' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TSTTT56_AUD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'DDR04' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56_AUD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TSTTT56_ZAR', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'DDR04' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56_ZAR' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TSTTT56_NZD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'DDR06' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56_NZD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
SELECT acct_grp_oid, 'EIS', 'EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56' AND acct_id_ctxt_typ='CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-5270-testing', NEW_OID FROM ft_t_acgr WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL
AND NOT EXISTS (SELECT 1 FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP1') AND acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TSTTT56' AND acct_id_ctxt_typ='CRTSID' and end_tms is null) AND acct_org_id = 'EIS' AND acct_bk_id='EIS' );

COMMIT