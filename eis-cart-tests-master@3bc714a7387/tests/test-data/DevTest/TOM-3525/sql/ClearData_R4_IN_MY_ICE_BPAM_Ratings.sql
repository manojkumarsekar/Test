delete from ft_t_isrt isrt
where instr_id in(select distinct instr_id from ft_t_isid where iss_id in('ESL7418182','ESL4608988','ESL2741151','ESL5631554') and id_ctxt_typ='EISLSTID');

commit;