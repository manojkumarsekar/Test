delete ft_T_acgp where prnt_acct_grp_oid='xY1M43%4G1' and acct_id in (select acct_id from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'TEST4996_N' AND end_tms is null);
delete ft_T_acgp where prnt_acct_grp_oid='xY1M43%4G1' and acct_id in (select acct_id from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'TEST4996_3' AND end_tms is null);
	
Insert into ft_t_acgp 
(prnt_acct_grp_oid,start_tms,acct_grp_oid,acct_org_id,acct_bk_id,acct_id,end_tms,part_rank_num,part_typ,prt_purp_typ,last_chg_tms,last_chg_usr_id,curr_cde,prt_desc,data_stat_typ,data_src_id,part_camt,part_cpct,acgp_oid)
select 'xY1M43%4G1',sysdate,null,'EIS ','EIS ',acct_id,null,null,null,'MEMBER  ',SYSDATE,'EIS:CSTM',null,'BRS Portfolio Group',null,'BRS',null,null,new_oid from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'TEST4996_N' AND end_tms is null;

Insert into ft_t_acgp 
(prnt_acct_grp_oid,start_tms,acct_grp_oid,acct_org_id,acct_bk_id,acct_id,end_tms,part_rank_num,part_typ,prt_purp_typ,last_chg_tms,last_chg_usr_id,curr_cde,prt_desc,data_stat_typ,data_src_id,part_camt,part_cpct,acgp_oid)
select 'xY1M43%4G1',sysdate,null,'EIS ','EIS ',acct_id,null,null,null,'MEMBER  ',SYSDATE,'EIS:CSTM',null,'BRS Portfolio Group',null,'BRS',null,null,new_oid from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'TEST4996_3' AND end_tms is null;

delete fT_T_acgp where acct_id in (select acct_id from fT_T_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'TEST4996_N' AND end_tms is null)
and PRNT_ACCT_GRP_OID in (select ACCT_GRP_OID from ft_T_acgr where acct_grp_id ='SGPOI');

delete ft_T_acgp where prnt_acct_grp_oid='xY1M43%4G1' and acct_id in (select acct_id from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'CANC4996_N' AND end_tms is null);
delete ft_T_acgp where prnt_acct_grp_oid='xY1M43%4G1' and acct_id in (select acct_id from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'CANC4996_3' AND end_tms is null);
	
Insert into ft_t_acgp 
(prnt_acct_grp_oid,start_tms,acct_grp_oid,acct_org_id,acct_bk_id,acct_id,end_tms,part_rank_num,part_typ,prt_purp_typ,last_chg_tms,last_chg_usr_id,curr_cde,prt_desc,data_stat_typ,data_src_id,part_camt,part_cpct,acgp_oid)
select 'xY1M43%4G1',sysdate,null,'EIS ','EIS ',acct_id,null,null,null,'MEMBER  ',SYSDATE,'EIS:CSTM',null,'BRS Portfolio Group',null,'BRS',null,null,new_oid from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'CANC4996_N' AND end_tms is null;

Insert into ft_t_acgp 
(prnt_acct_grp_oid,start_tms,acct_grp_oid,acct_org_id,acct_bk_id,acct_id,end_tms,part_rank_num,part_typ,prt_purp_typ,last_chg_tms,last_chg_usr_id,curr_cde,prt_desc,data_stat_typ,data_src_id,part_camt,part_cpct,acgp_oid)
select 'xY1M43%4G1',sysdate,null,'EIS ','EIS ',acct_id,null,null,null,'MEMBER  ',SYSDATE,'EIS:CSTM',null,'BRS Portfolio Group',null,'BRS',null,null,new_oid from ft_t_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'CANC4996_3' AND end_tms is null;

delete fT_T_acgp where acct_id in (select acct_id from fT_T_acid where acct_id_ctxt_Typ ='CRTSID' and ft_t_acid.acct_alt_id = 'CANC4996_N' AND end_tms is null)
and PRNT_ACCT_GRP_OID in (select ACCT_GRP_OID from ft_T_acgr where acct_grp_id ='SGPOI');