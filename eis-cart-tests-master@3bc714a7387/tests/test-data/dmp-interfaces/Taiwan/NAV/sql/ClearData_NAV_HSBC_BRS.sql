delete from ft_T_accv where acct_id  in (select acct_id from ft_T_accr where rep_acct_id  in (select acct_id from ft_T_acgp where prnt_acct_grp_oid  in (select acct_grp_oid from ft_t_acgr where acct_grp_id in ('TWFACAP1','TWFACAP2','TWFACAP3') and end_tms is null) and end_tms is null));

Insert into FT_T_ACCV (ORG_ID,BK_ID,ACCT_ID,TBL_TYP,VALU_TYP,VALU_CURR_CDE,AS_OF_TMS,VALU_ADJST_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,VALU_STAT_TYP,VALU_OPT_ID,OFFICIAL_NAV_IND,COLL_VAL_CAMT,CREDIT_LN_CAMT,VALU_VAL_CAMT,NAV_CRTE,SHR_OUTST_CQTY,DATA_SRC_ID,ORIG_DATA_PROV_ID) 
select 'EIS ','EIS ',(select acct_id from fT_T_acid where acct_alt_id = '4297SCN1SHRCLSS' and acct_id_ctxt_typ = 'SCSITCAFNDID' and end_tms is null),'ACCT','MRKT','TWD',sysdate-1,sysdate-1,sysdate-1,'EITW_HSBC_DMP_NAV_PRICE','Success ','ES00000001',null,null,null,10,11.2282,15591947.1,'HSBC',null from dual
WHERE NOT EXISTS (SELECT 1 FROM FT_T_ACCV WHERE ACCT_ID=(select acct_id from fT_T_acid where acct_alt_id = '4297SCN1SHRCLSS' and acct_id_ctxt_typ = 'CRTSID' and end_tms is null) AND VALU_VAL_CAMT=10);

Insert into FT_T_ACCV (ORG_ID,BK_ID,ACCT_ID,TBL_TYP,VALU_TYP,VALU_CURR_CDE,AS_OF_TMS,VALU_ADJST_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,VALU_STAT_TYP,VALU_OPT_ID,OFFICIAL_NAV_IND,COLL_VAL_CAMT,CREDIT_LN_CAMT,VALU_VAL_CAMT,NAV_CRTE,SHR_OUTST_CQTY,DATA_SRC_ID,ORIG_DATA_PROV_ID) 
select 'EIS ','EIS ',(select acct_id from fT_T_acid where acct_alt_id = '4297SCN2SHRCLSS' and acct_id_ctxt_typ = 'SCSITCAFNDID' and end_tms is null),'ACCT','MRKT','TWD',sysdate,sysdate,sysdate,'EITW_HSBC_DMP_NAV_PRICE','Success ','ES00000001',null,null,null,20,11.2282,15591947.1,'HSBC',null from dual
WHERE NOT EXISTS (SELECT 1 FROM FT_T_ACCV WHERE ACCT_ID=(select acct_id from fT_T_acid where acct_alt_id = '4297SCN2SHRCLSS' and acct_id_ctxt_typ = 'CRTSID' and end_tms is null) AND VALU_VAL_CAMT=20);

-- 4297SCN1SHRCLSS
INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', '4297SCN1PARENT_USD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN1SHRCLSS' AND acct_id_ctxt_typ='SCSITCAFNDID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN1PARENT_USD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
SELECT acct_grp_oid, 'EIS', 'EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN1PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-5270-testing', NEW_OID FROM ft_t_acgr WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL
AND NOT EXISTS (SELECT 1 FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP1') AND acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN1PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null) AND acct_org_id = 'EIS' AND acct_bk_id='EIS' );

-- 4297SCN2SHRCLSS
INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', '4297SCN2PARENT_USD', SYSDATE, SYSDATE, 'TOM-5270-testing', cross_ref_id FROM   ft_t_acct WHERE acct_id =  (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN2SHRCLSS' AND acct_id_ctxt_typ='CRTSID' and end_tms is null)
AND NOT EXISTS (SELECT 1 FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN2PARENT_USD' AND acct_id_ctxt_typ='CRTSID' AND END_TMS IS NULL);

INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
SELECT acct_grp_oid, 'EIS', 'EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN2PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-5270-testing', NEW_OID FROM ft_t_acgr WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL
AND NOT EXISTS (SELECT 1 FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP1') AND acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '4297SCN2PARENT' AND acct_id_ctxt_typ='CRTSID' and end_tms is null) AND acct_org_id = 'EIS' AND acct_bk_id='EIS' );

commit
