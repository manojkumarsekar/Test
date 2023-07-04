DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy'));

DELETE ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy');

delete from ft_t_iscl where indus_cl_set_id = 'BBMKTSCT' and instr_id in (select instr_id from ft_t_isid where id_ctxt_typ = 'ISIN' and iss_id in ('US01F0306948','US61765DAU28','US81748HAA77') and end_tms is null)

