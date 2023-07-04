update ft_t_isid set start_tms = sysdate-1, end_tms = sysdate-1 where iss_id = '${BCUSIP}' and id_ctxt_typ = 'BCUSIP' and end_tms is null;

update ft_t_isid set start_tms = sysdate-1, end_tms = sysdate-1 where iss_id = '${SEDOL}' and id_ctxt_typ = 'SEDOL' and end_tms is null;

commit;