Insert into FT_T_FINS (INST_MNEM,START_TMS,END_TMS,CROSS_REF_ID,ORG_ID,LAST_CHG_TMS,LAST_CHG_USR_ID,INST_NME,FISCAL_YR_END_TYP,INST_DESC,PREF_FINS_ID_CTXT_TYP,PREF_FINS_ID,INST_STAT_TYP,INST_TYP,INST_LEGAL_FORM_TYP,PUBLIC_CORP_IND,INST_FOUNDING_DTE,BAL_SHEET_CURR_CDE,DELETE_REAS_TYP,NLS_CDE,CMRCL_REGIST_ENTRY_DTE,CMRCL_REGIST_DELETE_DTE,BUSINESS_START_YR_TYP,IMPORT_EXPORT_AGENT_TYP,BUSINESS_STRUCTURE_TYP,SUBSIDIARY_IND,MAIL_DLVBLTY_TYP,DATA_STAT_TYP,DATA_SRC_ID,DUNS_HIER_CDE,DUNS_DIAS_CDE,DUNS_GLBL_ULT_IND,PREF_CURR_CDE,MAIL_ADDR_ID,ELEC_ADDR_ID,COMPANY_MATCH_ID,PREF_ISS_CTXT_TYP,INST_STAT_TMS,INCORPORATION_DTE,DISSOLUTION_DTE,INST_CAT_TYP,INCORPORATION_PLACE_TXT,INST_LEGAL_NME,ACQ_BY_PRNT_IND,OBLIGOR_SUBGRP_CLSF_OID,OBLIGOR_CL_VALUE,GOVT_AGENCY_FILING_IND,SEC_FORM_15_IND,FUND_SRCE_TYP,LEI_LEGAL_FORM_TXT,LEI_NME,LEI_RECORD_STAT_TXT,ASSOC_INST_MNEM,TERMIN_DTE)
SELECT NEW_OID,SYSDATE,null,null,null,SYSDATE,'EIS:CSTM','FIID_4140',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'EIS',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM FT_T_FINS WHERE INST_NME= 'FIID_4140' );


Insert into FT_T_FIID (FIID_OID,INST_MNEM,FINS_ID_CTXT_TYP,FINS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,INST_SYMBOL_STAT_TYP,DATA_STAT_TYP,DATA_SRC_ID,GU_ID,GU_TYP,GU_CNT,MERGE_UNIQ_OID,INST_USAGE_TYP,INST_SYMBOL_STAT_TMS,SRCE_INST_MNEM,GLOBAL_UNIQ_IND,INST_SYMBOL_RENEW_TMS) 
SELECT NEW_OID,FINS.INST_MNEM,'BRSTRDCNTCDE','FIID_4140',SYSDATE,null,SYSDATE,'EIS:CSTM',null,null,'EIS',null,null,null,null,null,null,null,'N',null
FROM FT_T_FINS FINS WHERE INST_NME= 'FIID_4140' AND  NOT EXISTS (SELECT 1 FROM FT_T_FIID FIID  WHERE FINS_ID_CTXT_TYP='BRSTRDCNTCDE'  AND FINS.INST_MNEM= FIID.INST_MNEM);


Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND) 
SELECT FINS.INST_MNEM,'BROKER',SYSDATE,'EIS:CSTM',null,null,null,NEW_OID,SYSDATE,null,null,null,null,null,null,null,null,null,null,null,null,null,'EIS',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
FROM FT_T_FINS FINS WHERE INST_NME= 'FIID_4140' AND  NOT EXISTS (SELECT 1 FROM FT_T_FINR FINR  WHERE FINSRL_TYP='BROKER' AND FINS.INST_MNEM= FINR.INST_MNEM);

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CROSS_REF_ID,START_TMS,FINSRL_NME,DATA_STAT_TYP)
 (SELECT INST_MNEM,'SBINVMGR',SYSDATE,'EIS:CSTM',new_oid,START_TMS,'EASTSPRING INVESTMENTS LIMITED','ACTIVE'
        FROM ft_T_fiid fiid
        where fins_id = 'ESI' and FINS_ID_CTXT_TYP = 'INHOUSE' and end_tms is null
        and not exists
        (select 1 from ft_t_finr where fiid.inst_mnem = inst_mnem and finsrl_typ = 'SBINVMGR')
  );


Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CROSS_REF_ID,START_TMS,DATA_STAT_TYP)
 (SELECT INST_MNEM,'SUBCUST',SYSDATE,'EIS:CSTM',new_oid,START_TMS,'ACTIVE'
        FROM ft_T_fiid fiid
        where fins_id = 'ES-SG' and FINS_ID_CTXT_TYP = 'INHOUSE' and end_tms is null
        and not exists
        (select 1 from ft_t_finr where fiid.inst_mnem = inst_mnem and finsrl_typ = 'SUBCUST')
  );

COMMIT;