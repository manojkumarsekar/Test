
--ISSU
Insert into FT_T_ISSU (INSTR_ID,ACCESS_AUTH_TYP,ISS_ACTVY_STAT_TYP,DENOM_CURR_CDE,END_TMS,INSTR_ISSR_ID,ISS_TMS,ISS_OBJ_TYP,ISS_TYP,ISS_UT_MEAS_TYP,MAT_EXP_TMS,PREF_ID_CTXT_TYP,START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,TRDG_RST_TYP,ISS_RATE_TXT,ISS_ALPH_SRCH_TXT,WHEN_ISSUED_IND,SEC_FORM_TYP,INDIV_CERTIF_IND,DEC_PREC_NUM,PRC_QT_METH_TYP,PRIN_NOTL_IND,EURO_CNVR_TYP,DFLT_STAT_TYP,DFLT_TMS,CL_TYP,SERIES_TYP,PART_FULL_PD_TYP,PREF_ISS_ID,PREF_ISS_NME,PREF_ISS_DESC,DATA_STAT_TYP,DATA_SRC_ID,PAR_VALUE_TYP,LIQUID_RIGHT_RANK_TYP,ISS_ACTVY_STAT_REAS_TYP,DLV_IND,DLV_REAS_CDE,MONITOR_RESTRICTION_CDE,DISTRIBUTION_CURR_CDE,INC_BAS_TYP,PRIN_BAS_TYP,WTHHLD_TAX_IND,WTHHLD_TAX_LEVIED_SRC_IND,TYP_EARN_FOR_LIFE_CDE,ISS_UT_CQTY,NOM_VAL_UNIT_CAMT,PRC_MLTPLR_CRTE,ISCD_OID,EIST_OID,ILLIQUIDITY_IND,NOT_TRADABLE_IND,BNCH_OID,ISS_TENOR_TYP,ORIG_MAT_EXP_TMS,MAT_EXP_DTE_EXTN_TMS,GOVT_SUPP_IND,AVR_EXEMPT_IND,SEC_LENDING_ELIG_IND,STRUCTURED_SEC_IND,MAND_CNVR_IND,TSFR_RST_IND,SUBSTITUTION_CLAUSE_IND,REPACKAGED_SEC_IND,MOST_FAVORED_LENDER_IND,RTNG_MAINT_PROVS_IND,MIN_NET_WORTH_BAL_IND,CNVR_TYP,TBA_ELIG_TYP,CREATED_TMS,ORIG_DATA_PROV_ID,DATA_REDISTRIBUTOR_ID,CREATED_REDISTRIBUTOR_ID,CREATED_DATA_PROV_ID,INVS_CLOSE_DTE,MAT_TYP,ISS_ACTVY_STAT_TMS,MKT_LIST_TYP,MAT_VAL_LNK_TYP,MAT_DTE_TYP,DFLT_TRDNG_STAT_TYP,REISSUE_TMS,FOREIGN_CUSTODY_IND,STRUCTURED_SEC_FEAT_TXT,ISS_YR_TYP,MAIN_RISK_TYP,GUARANTOR_TYP,ALT_ASSET_CLASS_TXT,FINAL_MAT_TMS,DAY_SETTLE_QTY,GUARANTEED_IND,GUARANTY_TYP,GUARANTY_RESTRICTIONS_TXT,MAT_DTE_EXTN_DLNE_DTE,CR_MAT_EXP_DTE_EXTN_TMS,CR_MAT_DTE_EXTN_DLNE_DTE,PREM_RSRV_FUND_ELIG_IND,HYBRID_IND) values (NEW_OID,'PUBLIC  ','ACTIVE  ','TWD',null,null,SYSDATE,null,'FUND',null,null,'CMONEY',SYSDATE,SYSDATE,'TEST_3970',null,null,null,'N',null,null,null,'PRCQUOTE','N',null,null,null,null,null,null,'TS3970000005','TEST_3970','TEST_3970','ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'FUND======',null,'N',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

--ISID

Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'RPN','TEST_3970',SYSDATE,null,SYSDATE,'TEST_3970',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TS3970000005' AND PREF_ISS_NME = 'TEST_3970' AND end_TMS IS NULL;
Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'ISIN','TS3970000005',SYSDATE,null,SYSDATE,'TEST_3970',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TS3970000005' AND PREF_ISS_NME = 'TEST_3970' AND END_TMS IS NULL;
Insert into FT_T_ISID (ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,LISTING_SYMBOL_IND,ERGONOMIC_SYMBOL_IND,TRADER_SYMBOL_IND,MULTI_SEDOL_SYMBOL_IND,INSTR_SYMBOL_STAT_TYP,WHEN_ISSUED_IND,MERGE_UNIQ_OID,ISS_TENOR_TYP,NOT_TRADABLE_IND,SRCE_CURR_CDE,TRGT_CURR_CDE,ROOT_SYMBOL_MNEM,GLOBAL_UNIQ_IND,ORIG_DATA_PROV_ID,WHEN_DISTRIBUTED_IND,INST_MNEM,PRELIM_TERM_PRSPCTUS_IND,PRIM_TRD_MRKT_QUOTE_IND) SELECT NEW_OID,INSTR_ID,'EISLSTID','ESL_TEST_3970',SYSDATE,null,SYSDATE,'TEST_3970',null,null,null,'ACTIVE','CMONEY',null,null,null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TS3970000005' AND PREF_ISS_NME = 'TEST_3970' AND end_TMS IS NULL;

Insert into FT_T_MKIS (MKT_ISS_OID,MKT_OID,INSTR_ID,ISS_TYP_GRP_OID,LAST_CHG_TMS,LAST_CHG_USR_ID,TRDNG_STAT_TYP,TRDNG_CURR_CDE,FIRST_TRDNG_TMS,LAST_TRDNG_TMS,TRDNG_FLOOR_LOC_ID,SPECIALIST_ID,PRC_UT_MEAS_TYP,TRDNG_UT_MEAS_TYP,PRC_CURR_CDE,ACRD_IN_FLAT_REAS_TYP,ISS_PRC_UNIT_TYP,ISID_OID,PRIM_TRD_MKT_IND,SETTLE_METH_TYP,SETTLE_CURR_CDE,DAILY_START_TME,DAILY_END_TME,NASDAQ_PORTAL_IND,SEASONED_IND,MRGN_SEC_IND,OPT_ELIG_IND,OPT_AVAIL_IND,TRDBOT_DY_TYP,TRDBOT_DY_NUM,TRDBOT_STRT_NUM,GU_ID,GU_TYP,GU_CNT,QUAL_ISID_OID,MKT_CLSF_CDE,TRD_LOT_SIZE_CQTY,START_TMS,DATA_STAT_TYP,DATA_SRC_ID,HOME_STOCK_EXCH_IND,FIXED_EXCH_RATE_IND,PARITY_PRICE_IND,TRD_SUSPEND_PRD_START_TMS,TRD_SUSPEND_PRD_END_TMS,OLD_QUOTE_CALC_METH_TYP,NEW_QUOTE_CALC_METH_TYP,NEW_QUOTE_METH_EFF_TMS,ISSU_QUOTE_STAT_CDE,ISS_TRD_UT_CQTY,PRC_MLTPLR_CRTE,PRC_PARTLY_PD_CAMT,ISS_PRC_UT_CAMT,ISS_PRC_UT_VOL_CAMT,RND_LOT_SZ_CQTY,NORM_MKT_SZ_CQTY,LOW_LMT_CPRC,UP_LMT_CPRC,SPACE_LOW_CQTY,SPACE_MED_CQTY,OPT_CRS_STRIKE_CPRC,HDG_INIT_ML_CAMT,HDG_MAINT_ML_CAMT,SPEC_INIT_ML_CAMT,SPEC_MAINT_ML_CAMT,END_TMS,MIFID_AVAIL_SHR_CQTY,MIFID_LIQUID_SHR_CQTY,MIFID_FREE_FLT_SHR_CQTY,MIFID_FREE_FLT_TO_CQTY,DAY_SETTLE_BUY_QTY,DAY_SETTLE_SLL_QTY,PREF_ISS_ID,MULT_SHR_IND,LISTING_TMS,DELISTING_TMS,PREF_ISS_CTXT_TYP,STL_LOC_TYP,STL_LOC_MNEM,STL_CYCLE_TYP,NO_SHORT_SELL_IND,NO_NAKED_SHORT_SELL_IND,SEC_SHORT_SALE_IND,PREF_PRC_TYP,LISTED_IND,OPOL_IND,ACTIVELY_TRADED_IND,SSE_SEHK_ELIG_IND,SSE_SEHK_QUOTE_STAT_TYP,DAYS_TO_SETTLE_QTY,DAYS_TO_SETTLE_TXT,SHORT_SALE_RST_TYP,MIFID_REGULATED_IND,EUSS_ELIG_IND,SEC_TICK_SZ_GRP_TYP,FULLY_FUNDED_IND,ETF_PRIN_RIC_TXT,EXCH_STOCK_CONNECT_TYP,EXCH_SC_QUOTE_STAT_TYP,TICK_SZ_CAMT,TICK_SZ_CURR_CDE,TICK_VAL_CURR_CDE,ISSR_REQ_TRDNG_IND,ISSR_APPRVL_TRDNG_TMS,ISSR_RQST_TRDNG_TMS,MKT_ISS_TYP,ADDNL_LISTING_QUAL_TYP,PROC_WHEN_ISSUED_IND,PROC_WHEN_DISTRIBUTED_IND,NON_TRADABLE_LISTING_IND) SELECT NEW_OID,'=0000000AC',INSTR_ID,null,SYSDATE,'TEST_3970','ACTIVE','USD',null,null,null,null,null,null,null,null,null,null,'N',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,SYSDATE,'ACTIVE','EIS',null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null FROM FT_T_ISSU WHERE PREF_ISS_ID = 'TS3970000005' AND PREF_ISS_NME = 'TEST_3970' AND end_TMS IS NULL;

Insert into FT_T_MIXR (MIXR_OID,ISID_OID,MKT_ISS_OID,START_TMS,END_TMS,TRDNG_STAT_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,DATA_STAT_TYP,DATA_SRC_ID) select NEW_OID,ISID.ISID_OID,MKIS.MKT_ISS_OID,SYSDATE,null,'ACTIVE',SYSDATE,'TEST_3970','ACTIVE','CMONEY' FROM FT_T_ISID ISID, FT_T_MKIS MKIS WHERE ISID.INSTR_ID=MKIS.INSTR_ID AND ISID.ISS_ID='ESL_TEST_3970' AND  ISID.ID_CTXT_TYP='EISLSTID' AND ISID.END_TMS IS NULL AND MKIS.END_TMS IS NULL;

COMMIT;