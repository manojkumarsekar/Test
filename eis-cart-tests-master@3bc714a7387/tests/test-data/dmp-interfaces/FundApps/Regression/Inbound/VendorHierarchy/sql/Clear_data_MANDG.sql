UPDATE ft_t_isid set end_tms =sysdate-1 , start_tms = sysdate-1 where instr_id in (select instr_id from ft_t_isid where iss_id ='6054603' and id_ctxt_typ = 'MNGCODE') and  id_ctxt_typ = 'MNGCODE' and end_tms is null and  last_chg_usr_id ='EIS_RCRLBU_DMP_SECURITY';
UPDATE ft_t_isid set end_tms =sysdate-1 , start_tms = sysdate-1 where instr_id in (select instr_id from ft_t_isid where iss_id ='JP3111200006' and id_ctxt_typ = 'ISIN')and  id_ctxt_typ = 'ISIN' and end_tms is null and  last_chg_usr_id ='EIS_RCRLBU_DMP_SECURITY';
UPDATE ft_t_isid set end_tms =sysdate-1 , start_tms = sysdate-1 where instr_id in (select instr_id from ft_t_isid where iss_id ='J0242P110' and id_ctxt_typ = 'CUSIP') and  id_ctxt_typ = 'CUSIP' and end_tms is null and  last_chg_usr_id ='EIS_RCRLBU_DMP_SECURITY';
UPDATE ft_t_isid set end_tms =sysdate-1 , start_tms = sysdate-1 where instr_id in (select instr_id from ft_t_isid where iss_id ='6054603' and id_ctxt_typ = 'SEDOL') and  id_ctxt_typ = 'SEDOL' and end_tms is null and  last_chg_usr_id ='EIS_RCRLBU_DMP_SECURITY';