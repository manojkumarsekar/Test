SELECT     Count(1) AS ISRT_COUNT 
FROM       ft_t_isrt isrt
inner join ft_t_isid isid on isrt.instr_id = isid.instr_id AND isid.id_ctxt_typ='ISIN'
WHERE Trunc(isrt.last_chg_tms) = Trunc(SYSDATE) AND isrt.end_tms is null AND isid.end_tms is null
AND isrt.orig_data_prov_id='CARE' AND isrt.data_stat_typ='ACTIVE' 
and rtng_set_oid in(SELECT rtng_set_oid FROM ft_t_rtng WHERE rtng_set_mnem = 'CARERT')
AND ((isid.iss_id ='INE134E08II2' and rtng_cde='AAA' AND rtng_eff_tms=to_date('20160812','YYYYMMDD'))
OR (isid.iss_id ='INE053F07603' and rtng_cde='AAA' AND rtng_eff_tms=to_date('20130315','YYYYMMDD'))
OR (isid.iss_id ='INE134E08HV7' and rtng_cde='AAA' AND rtng_eff_tms=to_date('20150904','YYYYMMDD'))
OR (isid.iss_id ='INE038A07274' and rtng_cde='AA+' AND rtng_eff_tms=to_date('20170926','YYYYMMDD'))
)

