delete from ft_T_accv where acct_id  in (select acct_id from ft_T_accr where rep_acct_id  in (select acct_id from ft_T_acgp where prnt_acct_grp_oid  in (select acct_grp_oid from ft_t_acgr where acct_grp_id in ('TWFACAP1','TWFACAP2','TWFACAP3') and end_tms is null) and end_tms is null));

--Data SetUp for SCSITCAFNDID(SCN1SHRCLSS) AND PART OF TWFACAP1 ACCOUNT GROUP

     --Shareclass insert SCN1SHRCLSS
INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'SCN1PARENT_USD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN1SHRCLSS' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN1PARENT_USD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
SELECT acct_grp_oid, 'EIS', 'EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN1PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-5270-testing', NEW_OID FROM ft_t_acgr WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL
AND NOT EXISTS (SELECT 1 FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP1') AND acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN1PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null) AND acct_org_id = 'EIS' AND acct_bk_id='EIS' );


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Data SetUp for SCSITCAFNDID(SCN2SHRCLSS) AND PART OF TWFACAP2 ACCOUNT GROUP

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'SCN2PARENT_USD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN2SHRCLSS' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN2PARENT_USD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
SELECT acct_grp_oid, 'EIS', 'EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN2PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-5270-testing', NEW_OID FROM ft_t_acgr WHERE acct_grp_id = 'TWFACAP2' AND end_tms IS NULL
AND NOT EXISTS (SELECT 1 FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP2') AND acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN2PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null) AND acct_org_id = 'EIS' AND acct_bk_id='EIS' );


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Data SetUp for SCSITCAFNDID(SCN3SHRCLSS) AND PART OF TWFACAP3 ACCOUNT GROUP

     --Shareclass insert SCN3SHRCLSS
INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'SCN3PARENT_USD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN3SHRCLSS' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN3PARENT_USD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
SELECT acct_grp_oid, 'EIS', 'EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN3PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-5270-testing', NEW_OID FROM ft_t_acgr WHERE acct_grp_id = 'TWFACAP3' AND end_tms IS NULL
AND NOT EXISTS (SELECT 1 FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP3') AND acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN3PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null) AND acct_org_id = 'EIS' AND acct_bk_id='EIS' );



commit