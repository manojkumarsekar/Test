update ft_t_iscl set end_tms= SYSDATE-1 where instr_id in (select instr_id from ft_T_isid where iss_id = 'IE00BZ036H21' and end_tms is null) and indus_cl_set_id = 'RDMSCTYP' and cl_value = 'COM' and end_tms is null;