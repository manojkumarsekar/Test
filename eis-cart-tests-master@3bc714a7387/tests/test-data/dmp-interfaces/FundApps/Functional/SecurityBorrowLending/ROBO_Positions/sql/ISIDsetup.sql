Insert into FT_T_ISID
(ISID_OID,INSTR_ID,ID_CTXT_TYP,ISS_ID,START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MKT_OID,TRDNG_CURR_CDE,ISS_USAGE_TYP,DATA_STAT_TYP,DATA_SRC_ID,
GLOBAL_UNIQ_IND)
select
'AB${DYNAMIC_FILE_DATE}',(select instr_id from ft_t_isid where iss_id='0490656' and id_ctxt_typ='SEDOL' and end_tms is null and rownum=1),
'SEDOL','0490656',SYSDATE,SYSDATE,'TEST',(select MKT_OID from ft_t_mkid where mkt_id='ZZZZ' and mkt_id_ctxt_typ='MIC' and rownum=1),
null,'0490656','ACTIVE','EIS','N' from dual where not exists (select 1 from ft_t_isid where isid_oid='AB${DYNAMIC_FILE_DATE}');