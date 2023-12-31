Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'FMC',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='FMC' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'ACCTAGNT',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='ACCTAGNT' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-SG' and FINS_ID_CTXT_TYP='INHOUSE'),'TRUSTEE',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='TRUSTEE' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'VALAGENT',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='VALAGENT' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'REGSTR',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='REGSTR' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'SBTRFAGT',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='SBTRFAGT' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'GLBDISTB',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='GLBDISTB' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'TRAGENT',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='TRAGENT' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'FUNDADM',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='FUNDADM' and LAST_CHG_USR_ID='EIS:CSTM');

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'CUSTDIAN',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='CUSTDIAN' and LAST_CHG_USR_ID='EIS:CSTM' and INST_MNEM in (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE') );

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,
VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,
END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,
DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,
PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND)
select (select inst_mnem from ft_T_fiid where fins_id='ES-AWMY' and FINS_ID_CTXT_TYP='INHOUSE'),'SBRGSTAR',sysdate,'EIS:CSTM',null,null,null,new_oid,
sysdate,null,null,null,null,null,null,NULL,null,null,null,null,null,'ACTIVE',null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from dual where not exists (select 1 from ft_t_finr
where FINSRL_TYP='SBRGSTAR' and LAST_CHG_USR_ID='EIS:CSTM');

commit;