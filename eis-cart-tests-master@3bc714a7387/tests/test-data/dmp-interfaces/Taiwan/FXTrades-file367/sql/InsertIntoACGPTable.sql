insert into ft_t_acgp
select (select ACCT_GRP_OID from ft_t_acgr where ACCT_GRP_ID ='TW_SHC'),SYSDATE,null,'EIS ','EIS ',(select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${SHARE_PORTFOLIO_NAME}' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS is NULL),null,null,null,'MEMBER  ',SYSDATE,'EIS_RDM_DMP_PORTFOLIO_MASTER',null,'','ACTIVE','EIS',null,null, new_oid()
FROM   DUAL
WHERE  NOT EXISTS (SELECT 1 FROM ft_t_acgp WHERE acct_id IN (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${SHARE_PORTFOLIO_NAME}' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS is NULL) and prnt_acct_grp_oid = (select ACCT_GRP_OID from ft_t_acgr where ACCT_GRP_ID ='TW_SHC'));

insert into ft_t_acgp
select (select ACCT_GRP_OID from ft_t_acgr where ACCT_GRP_ID ='TW_SHC'),SYSDATE,null,'EIS ','EIS ',(select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${MAIN_PORTFOLIO_NAME}' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS is NULL),null,null,null,'MEMBER  ',SYSDATE,'EIS_RDM_DMP_PORTFOLIO_MASTER',null,'','ACTIVE','EIS',null,null, new_oid()
FROM   DUAL
WHERE  NOT EXISTS (SELECT 1 FROM ft_t_acgp WHERE acct_id IN (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${MAIN_PORTFOLIO_NAME}' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS is NULL) and prnt_acct_grp_oid = (select ACCT_GRP_OID from ft_t_acgr where ACCT_GRP_ID ='TW_SHC'));


insert into ft_t_acgp
select (select ACCT_GRP_OID from ft_t_acgr where ACCT_GRP_ID ='TW_SHC'),SYSDATE,null,'EIS ','EIS ',(select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${SPLIT_PORTFOLIO_NAME}' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS is NULL),null,null,null,'MEMBER  ',SYSDATE,'EIS_RDM_DMP_PORTFOLIO_MASTER',null,'','ACTIVE','EIS',null,null, new_oid()
FROM   DUAL
WHERE  NOT EXISTS (SELECT 1 FROM ft_t_acgp WHERE acct_id IN (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${SPLIT_PORTFOLIO_NAME}' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS is NULL) and prnt_acct_grp_oid = (select ACCT_GRP_OID from ft_t_acgr where ACCT_GRP_ID ='TW_SHC'));

COMMIT;