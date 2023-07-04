
--ISSU
Insert into FT_T_ISSU (INSTR_ID,ACCESS_AUTH_TYP,ISS_ACTVY_STAT_TYP,DENOM_CURR_CDE,END_TMS,INSTR_ISSR_ID,ISS_TMS,ISS_OBJ_TYP,ISS_TYP,ISS_UT_MEAS_TYP,MAT_EXP_TMS,PREF_ID_CTXT_TYP,START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,TRDG_RST_TYP,ISS_RATE_TXT,ISS_ALPH_SRCH_TXT,WHEN_ISSUED_IND,SEC_FORM_TYP,INDIV_CERTIF_IND,DEC_PREC_NUM,PRC_QT_METH_TYP,PRIN_NOTL_IND,EURO_CNVR_TYP,DFLT_STAT_TYP,DFLT_TMS,CL_TYP,SERIES_TYP,PART_FULL_PD_TYP,PREF_ISS_ID,PREF_ISS_NME,PREF_ISS_DESC,DATA_STAT_TYP,DATA_SRC_ID,PAR_VALUE_TYP,LIQUID_RIGHT_RANK_TYP,ISS_ACTVY_STAT_REAS_TYP,DLV_IND,DLV_REAS_CDE,MONITOR_RESTRICTION_CDE,DISTRIBUTION_CURR_CDE,INC_BAS_TYP,PRIN_BAS_TYP,WTHHLD_TAX_IND,WTHHLD_TAX_LEVIED_SRC_IND,TYP_EARN_FOR_LIFE_CDE,ISS_UT_CQTY,NOM_VAL_UNIT_CAMT,PRC_MLTPLR_CRTE,ISCD_OID,EIST_OID,ILLIQUIDITY_IND,NOT_TRADABLE_IND,BNCH_OID,ISS_TENOR_TYP,ORIG_MAT_EXP_TMS,MAT_EXP_DTE_EXTN_TMS,GOVT_SUPP_IND,AVR_EXEMPT_IND,SEC_LENDING_ELIG_IND,STRUCTURED_SEC_IND,MAND_CNVR_IND,TSFR_RST_IND,SUBSTITUTION_CLAUSE_IND,REPACKAGED_SEC_IND,MOST_FAVORED_LENDER_IND,RTNG_MAINT_PROVS_IND,MIN_NET_WORTH_BAL_IND,CNVR_TYP,TBA_ELIG_TYP,CREATED_TMS,ORIG_DATA_PROV_ID,DATA_REDISTRIBUTOR_ID,CREATED_REDISTRIBUTOR_ID,CREATED_DATA_PROV_ID,INVS_CLOSE_DTE,MAT_TYP,ISS_ACTVY_STAT_TMS,MKT_LIST_TYP,MAT_VAL_LNK_TYP,MAT_DTE_TYP,DFLT_TRDNG_STAT_TYP,REISSUE_TMS,FOREIGN_CUSTODY_IND,STRUCTURED_SEC_FEAT_TXT,ISS_YR_TYP,MAIN_RISK_TYP,GUARANTOR_TYP,ALT_ASSET_CLASS_TXT,FINAL_MAT_TMS,DAY_SETTLE_QTY,GUARANTEED_IND,GUARANTY_TYP,GUARANTY_RESTRICTIONS_TXT,MAT_DTE_EXTN_DLNE_DTE,CR_MAT_EXP_DTE_EXTN_TMS,CR_MAT_DTE_EXTN_DLNE_DTE,PREM_RSRV_FUND_ELIG_IND,HYBRID_IND) values (NEW_OID,'PUBLIC  ','ACTIVE  ','TWD',null,null,SYSDATE,null,'FUND',null,null,'CMONEY',SYSDATE,SYSDATE,'TEST_3680',null,null,null,'N',null,null,null,'PRCQUOTE','N',null,null,null,null,null,null,'TS3680000006','TEST_3680','TEST_3680','ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'FUND======',null,'N',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

--ISID

Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'RPN','TEST_3680',SYSDATE,null,SYSDATE,'TEST_3680',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TS3680000006' AND PREF_ISS_NME = 'TEST_3680' AND end_TMS IS NULL;
Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'ISIN','TS3680000006',SYSDATE,null,SYSDATE,'TEST_3680',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TS3680000006' AND PREF_ISS_NME = 'TEST_3680' AND END_TMS IS NULL;


--ISSU
Insert into FT_T_ISSU (INSTR_ID,ACCESS_AUTH_TYP,ISS_ACTVY_STAT_TYP,DENOM_CURR_CDE,END_TMS,INSTR_ISSR_ID,ISS_TMS,ISS_OBJ_TYP,ISS_TYP,ISS_UT_MEAS_TYP,MAT_EXP_TMS,PREF_ID_CTXT_TYP,START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,TRDG_RST_TYP,ISS_RATE_TXT,ISS_ALPH_SRCH_TXT,WHEN_ISSUED_IND,SEC_FORM_TYP,INDIV_CERTIF_IND,DEC_PREC_NUM,PRC_QT_METH_TYP,PRIN_NOTL_IND,EURO_CNVR_TYP,DFLT_STAT_TYP,DFLT_TMS,CL_TYP,SERIES_TYP,PART_FULL_PD_TYP,PREF_ISS_ID,PREF_ISS_NME,PREF_ISS_DESC,DATA_STAT_TYP,DATA_SRC_ID,PAR_VALUE_TYP,LIQUID_RIGHT_RANK_TYP,ISS_ACTVY_STAT_REAS_TYP,DLV_IND,DLV_REAS_CDE,MONITOR_RESTRICTION_CDE,DISTRIBUTION_CURR_CDE,INC_BAS_TYP,PRIN_BAS_TYP,WTHHLD_TAX_IND,WTHHLD_TAX_LEVIED_SRC_IND,TYP_EARN_FOR_LIFE_CDE,ISS_UT_CQTY,NOM_VAL_UNIT_CAMT,PRC_MLTPLR_CRTE,ISCD_OID,EIST_OID,ILLIQUIDITY_IND,NOT_TRADABLE_IND,BNCH_OID,ISS_TENOR_TYP,ORIG_MAT_EXP_TMS,MAT_EXP_DTE_EXTN_TMS,GOVT_SUPP_IND,AVR_EXEMPT_IND,SEC_LENDING_ELIG_IND,STRUCTURED_SEC_IND,MAND_CNVR_IND,TSFR_RST_IND,SUBSTITUTION_CLAUSE_IND,REPACKAGED_SEC_IND,MOST_FAVORED_LENDER_IND,RTNG_MAINT_PROVS_IND,MIN_NET_WORTH_BAL_IND,CNVR_TYP,TBA_ELIG_TYP,CREATED_TMS,ORIG_DATA_PROV_ID,DATA_REDISTRIBUTOR_ID,CREATED_REDISTRIBUTOR_ID,CREATED_DATA_PROV_ID,INVS_CLOSE_DTE,MAT_TYP,ISS_ACTVY_STAT_TMS,MKT_LIST_TYP,MAT_VAL_LNK_TYP,MAT_DTE_TYP,DFLT_TRDNG_STAT_TYP,REISSUE_TMS,FOREIGN_CUSTODY_IND,STRUCTURED_SEC_FEAT_TXT,ISS_YR_TYP,MAIN_RISK_TYP,GUARANTOR_TYP,ALT_ASSET_CLASS_TXT,FINAL_MAT_TMS,DAY_SETTLE_QTY,GUARANTEED_IND,GUARANTY_TYP,GUARANTY_RESTRICTIONS_TXT,MAT_DTE_EXTN_DLNE_DTE,CR_MAT_EXP_DTE_EXTN_TMS,CR_MAT_DTE_EXTN_DLNE_DTE,PREM_RSRV_FUND_ELIG_IND,HYBRID_IND) values (NEW_OID ,'PUBLIC  ','ACTIVE  ','TWD',null,null,SYSDATE,null,'FUND',null,null,'CMONEY',SYSDATE,SYSDATE,'TEST3680_1',null,null,null,'N',null,null,null,'PRCQUOTE','N',null,null,null,null,null,null,'TE3680000002','TEST3680_1','TEST3680_1','ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'FUND======',null,'N',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'RPN','TEST3680_1',SYSDATE,null,SYSDATE,'TEST3680_1',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TE3680000002' AND PREF_ISS_NME = 'TEST3680_1' AND END_TMS IS NULL;

Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'ISIN','TE3680000002',SYSDATE,null,SYSDATE,'TEST3680_1',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TE3680000002' AND PREF_ISS_NME = 'TEST3680_1' AND END_TMS IS NULL;

Insert into FT_T_FINS (INST_MNEM,START_TMS,END_TMS,CROSS_REF_ID,ORG_ID,LAST_CHG_TMS,LAST_CHG_USR_ID,INST_NME,FISCAL_YR_END_TYP,INST_DESC,
PREF_FINS_ID_CTXT_TYP,PREF_FINS_ID,INST_STAT_TYP,INST_TYP,INST_LEGAL_FORM_TYP,PUBLIC_CORP_IND,INST_FOUNDING_DTE,BAL_SHEET_CURR_CDE,
DELETE_REAS_TYP,NLS_CDE,CMRCL_REGIST_ENTRY_DTE,CMRCL_REGIST_DELETE_DTE,BUSINESS_START_YR_TYP,IMPORT_EXPORT_AGENT_TYP,BUSINESS_STRUCTURE_TYP,SUBSIDIARY_IND,MAIL_DLVBLTY_TYP,DATA_STAT_TYP,DATA_SRC_ID,DUNS_HIER_CDE,DUNS_DIAS_CDE,DUNS_GLBL_ULT_IND,PREF_CURR_CDE,MAIL_ADDR_ID,ELEC_ADDR_ID,COMPANY_MATCH_ID,PREF_ISS_CTXT_TYP,INST_STAT_TMS,INCORPORATION_DTE,DISSOLUTION_DTE,INST_CAT_TYP,INCORPORATION_PLACE_TXT,INST_LEGAL_NME,ACQ_BY_PRNT_IND,OBLIGOR_SUBGRP_CLSF_OID,OBLIGOR_CL_VALUE,GOVT_AGENCY_FILING_IND,SEC_FORM_15_IND,FUND_SRCE_TYP,LEI_LEGAL_FORM_TXT,LEI_NME,LEI_RECORD_STAT_TXT,ASSOC_INST_MNEM,TERMIN_DTE,INVEST_FIRM_IND,FILF_OID,HOLDING_COMPANY_IND) values (NEW_OID,SYSDATE,null,null,null,SYSDATE,'TEST_3680','TEST3680',null,'TEST3680','CMONEY','TEST3680_1','Y',null,null,null,null,null,null,null,null,null,null,null,null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,SYSDATE,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CAL_ID,DAYS_TYP,ACTS_PYNG_AGNT_IND,CROSS_REF_ID,START_TMS,END_TMS,VAL_DAYS_OF_NUM,TRD_RPTG_MNEM,FINSRL_CONTCT_TXT,FINSRL_DESC,NOFIX_SETTLE_DESC,FINSRL_NME,PREF_ID_CTXT_TYP,START_BUS_DY_TME,END_BUS_DY_TME,SRO_JURIS_EFF_DTE,CONTCT_OID,DATA_STAT_TYP,DATA_SRC_ID,PREF_CURR_CDE,PREF_FINR_ID,MAIL_ADDR_ID,ELEC_ADDR_ID,RCPT_PAY_TYP,DLV_PAY_TYP,AUTH_UK_INTERMEDIARY_IND,DFLT_CORR_BNK_IND,FINSRL_SUB_TYP,QI_CAPACITY_TYP,CLAIM_IND,FINSRL_STAT_TYP,FINSRL_STAT_TMS,PREF_ISS_CTXT_TYP,CLIENT_SRVC_TYP,WEB_PORTAL_IND,CLIENT_RST_IND,PRIN_REG_JURIS_ID,PREF_SETTLE_TYP,PAY_METH_TYP,MSG_FMT_MNEM,GLOBAL_DATA_PROV_IND) SELECT INST_MNEM,'ISSUER  ',SYSDATE,'TEST_3680',null,null,null,INST_MNEM,SYSDATE,null,null,null,null,null,null,null,null,null,null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null FROM FT_T_FINS WHERE INST_NME = 'TEST3680' AND END_TMS IS NULL;

Insert into FT_T_FRIP (FINSRL_ISS_PRT_ID,INST_MNEM,FINSRL_TYP,INSTR_ID,PRT_PURP_TYP,START_TMS,END_TMS,ISS_UT_MEAS_TYP,ISS_UT_PURP_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,ISS_TYP_GRP_OID,CSH_STL_DAYS_CNT,DATA_STAT_TYP,DATA_SRC_ID,ISS_UT_CQTY,ISID_OID,PAY_RECV_TYP,PART_CAMT,PART_CURR_CDE,PART_CPCT,PRIM_REL_IND,REL_STAT_TYP,REL_STAT_TMS,INST_NME,INST_RL_TYP,INST_CITY_NME,INST_STE_PRV_CDE,
INST_ROUTING_ID,FINS_INST_MNEM,COMM_CRTE,INIT_MARGIN_CPCT,FRRL_OID,OBLIGATION_PREF_IND,OBLIGATION_PREF_DTE,OBLIGATION_PREF_EXP_DTE,
INIT_MARGIN_CAMT) SELECT NEW_OID,INST_MNEM,'ISSUER',(SELECT INSTR_ID FROM FT_T_ISSU
WHERE PREF_ISS_ID = 'TE3680000002' AND PREF_ISS_NME = 'TEST3680_1' AND END_TMS IS NULL),'BRSISSR',SYSDATE,null,null,null,SYSDATE,'TEST_3680',null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,nulL FROM FT_T_FINS WHERE INST_NME = 'TEST3680' AND END_TMS IS NULL;

COMMIT;