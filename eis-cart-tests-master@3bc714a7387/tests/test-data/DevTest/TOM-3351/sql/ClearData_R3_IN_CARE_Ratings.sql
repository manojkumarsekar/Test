delete from ft_t_isrt isrt
where instr_id in(select distinct instr_id from ft_t_isid where iss_id in('INE134E08II2','INE053F07603','INE134E08HV7','INE038A07274') and id_ctxt_typ='ISIN')
and rtng_set_oid in(SELECT rtng_set_oid FROM ft_t_rtng WHERE rtng_set_mnem = 'CARERT');

commit;