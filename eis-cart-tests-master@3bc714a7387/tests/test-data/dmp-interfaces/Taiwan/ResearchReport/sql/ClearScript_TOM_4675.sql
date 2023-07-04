delete ft_T_msgf where trn_id in (select trn_id from ft_T_trid where job_id in (select job_id from fT_T_jblg
where prnt_job_id='00TEST4675eXu001'));
delete ft_o_rsrt where job_id in (select job_id from fT_T_jblg
where prnt_job_id='00TEST4675eXu001');
delete ft_t_trid where job_id in (select job_id from fT_T_jblg
where prnt_job_id='00TEST4675eXu001');
delete ft_T_jblg where job_id in (select job_id from fT_T_jblg
where prnt_job_id='00TEST4675eXu001');
delete fT_T_jblg
where job_id='00TEST4675eXu001';
delete fT_T_rsp1 where rsr1_oid in (select rsr1_oid from FT_T_RSR1 WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM01JN51' AND END_TMS IS NULL)
AND (EXT_RSRSH_ID LIKE '%29410%' OR EXT_RSRSH_ID LIKE '%29411%'));
delete FT_T_RSR1 WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM01JN51' AND END_TMS IS NULL)
AND (EXT_RSRSH_ID LIKE '%29410%' OR EXT_RSRSH_ID LIKE '%29411%');

Insert into FT_T_JBLG (JOB_ID,RQST_TRN_ID,JOB_STAT_TYP,JOB_START_TMS,JOB_END_TMS,TASK_TOT_CNT,TASK_CMPLTD_CNT,JOB_INPUT_TXT,
JOB_CONFIG_TXT,RQST_CORR_ID,TASK_SUCCESS_CNT,TASK_FAILED_CNT,LAST_UPD_TMS,MAX_RECORD_SEQ_NUM,PRNT_JOB_ID,JOB_MSG_TYP,JOB_TME_TXT,
JOB_TPS_CNT,TASK_PARTIAL_CNT,TASK_FILTERED_CNT,INSTANCE_ID,PEVL_OID,JBDF_OID) select '00TEST4675eXu001',null,'CLOSED  ',
SYSDATE,SYSDATE,0,0,null,
'EIS_ResearchReportWrapper',null,0,0,SYSDATE,null,null,null,'00:01:15',0,0,0,
'017KyODWh5eXu00W',null,null from dual where not exists (select 1 from ft_T_jblg where job_id='00TEST4675eXu001');
COMMIT;