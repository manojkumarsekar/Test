DELETE FT_T_ISGP
     WHERE prnt_iss_grp_oid='BICSREQSOI'
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID IN ('BPM0C6UC4','BPM0MWN34','TEST123','BPM0NPVT2','BRSFPV233','BES32M4A6','BES34TBQ6')
       AND END_TMS IS NULL);

DELETE FT_T_ISCL
     WHERE INDUS_CL_SET_ID='BICSSECT'
     AND END_TMS is NULL
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID IN ('BPM0C6UC4','BPM0MWN34','TEST123','BPM0NPVT2','BRSFPV233','BES32M4A6','BES34TBQ6')
       AND END_TMS IS NULL);

Insert into FT_T_JBLG (JOB_ID,RQST_TRN_ID,JOB_STAT_TYP,JOB_START_TMS,JOB_END_TMS,TASK_TOT_CNT,TASK_CMPLTD_CNT,JOB_INPUT_TXT,JOB_CONFIG_TXT,RQST_CORR_ID,TASK_SUCCESS_CNT,TASK_FAILED_CNT,LAST_UPD_TMS,MAX_RECORD_SEQ_NUM,PRNT_JOB_ID,JOB_MSG_TYP,JOB_TME_TXT,JOB_TPS_CNT,TASK_PARTIAL_CNT,TASK_FILTERED_CNT,INSTANCE_ID,PEVL_OID,JBDF_OID)
      values (new_oid,null,'CLOSED  ',sysdate,sysdate,1,1,null,'EIS_BICSBBRequestReply',null,1,0,sysdate,0,null,null,'00:00:00',null,0,0,null,null,null);