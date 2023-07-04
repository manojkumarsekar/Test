Insert into FT_T_ACGP (PRNT_ACCT_GRP_OID,START_TMS,ACCT_ORG_ID,ACCT_BK_ID,ACCT_ID,PRT_PURP_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,ACGP_OID)
select (select acct_grp_oid from ft_t_acgr where GRP_NME = 'TWNLILP' and end_tms is null),sysdate,'EIS ','EIS ',(select ACCT_ID from ft_t_acid where acct_alt_id in ('DDM01') and ACCT_ID_CTXT_TYP  = 'SCSITCAFNDID' and end_tms is null),'MEMBER  ',sysdate,'EIS:CSTM',new_oid from dual
where not exists (select 1 from ft_t_acgp where PRNT_ACCT_GRP_OID in (select acct_grp_oid from ft_t_acgr where GRP_NME = 'TWNLILP' and end_tms is null) and acct_id = (select ACCT_ID from ft_t_acid where acct_alt_id in ('DDM01') and ACCT_ID_CTXT_TYP  = 'SCSITCAFNDID' and end_tms is null));

commit