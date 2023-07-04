SELECT     Count(1) AS RELOAD_INACTIVE_ROW_COUNT
FROM       ft_t_isrt isrt
inner join ft_t_isid isid on isrt.instr_id = isid.instr_id AND isid.id_ctxt_typ='EISLSTID'
WHERE Trunc(isrt.last_chg_tms) = Trunc(SYSDATE) AND isrt.end_tms is NOT null AND isid.end_tms is null
AND isrt.data_src_id='ICE APEX' AND isrt.data_stat_typ='ACTIVE' AND isrt.data_redistributor_id = 'ICE APEX'
AND isid.iss_id in('ESL7418182','ESL4608988','ESL2741151','ESL5631554')
