DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy'));

DELETE ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy');

delete from ft_t_iscl where indus_cl_set_id = 'BBMKTSCT' and instr_id in (select instr_id from ft_t_isid where id_ctxt_typ = 'ISIN' and iss_id in ('LU0326391785', 'TH1060010002', 'LU0229866941', 'TH0347010017') and end_tms is null);

update ft_t_isid set start_tms = sysdate-2, end_tms = sysdate-1 where id_ctxt_typ = 'BBGLOBAL' and iss_id in ('BBG001XZLBR6','BBG001MKYJB7','BBG000HCBSF4','BBG002HFCQY5') and end_tms is null