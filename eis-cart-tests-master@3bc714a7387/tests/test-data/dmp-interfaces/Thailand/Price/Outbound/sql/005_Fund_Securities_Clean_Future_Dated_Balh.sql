DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy'));

DELETE ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy');

update ft_t_iscl set end_tms=sysdate where indus_cl_set_id = 'BBMKTSCT' and instr_id in (select instr_id from ft_t_isid where id_ctxt_typ in ('ISIN') and iss_id in ('TW000T0712Y7') and end_tms is null)

