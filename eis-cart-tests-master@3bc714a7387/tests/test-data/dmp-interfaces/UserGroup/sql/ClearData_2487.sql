delete fT_t_gnst where cross_ref_id in (select fpro_oid from ft_t_fpro where fins_pro_id in ('test1@eastspring.com','test2@eastspring.com','test3@eastspring.com'));
delete fT_t_fpgu where fpro_oid in (select fpro_oid from ft_t_fpro where fins_pro_id in ('test1@eastspring.com','test2@eastspring.com','test3@eastspring.com'));
delete fT_t_fpid where fpro_oid in (select fpro_oid from ft_t_fpro where fins_pro_id in ('test1@eastspring.com','test2@eastspring.com','test3@eastspring.com'));
delete fT_t_adtp where fpro_oid in (select fpro_oid from ft_t_fpro where fins_pro_id in ('test1@eastspring.com','test2@eastspring.com','test3@eastspring.com'));
delete ft_t_udf1 where fpro_oid in (select fpro_oid from ft_t_fpro where fins_pro_id in ('test1@eastspring.com','test2@eastspring.com','test3@eastspring.com'));
delete ft_t_fpro where fins_pro_id in ('test1@eastspring.com','test2@eastspring.com','test3@eastspring.com');
DELETE FT_t_IDMV WHERE INTRNL_DMN_VAL_NME IN ('TEST_CDF_TAG','CDF_MISSING') AND FLD_ID ='CDF1002';
DELETE FT_t_IDMV WHERE INTRNL_DMN_VAL_NME IN ('Test_CDF_TAG','CDF_MISSING') AND FLD_ID ='CDF2002';
DELETE FT_T_TRID WHERE MAIN_ENTITY_ID_CTXT_TYP='CDF Updated User';
Insert into FT_T_JBLG (JOB_ID,RQST_TRN_ID,JOB_STAT_TYP,JOB_START_TMS,JOB_END_TMS,TASK_TOT_CNT,TASK_CMPLTD_CNT,JOB_INPUT_TXT,JOB_CONFIG_TXT,RQST_CORR_ID,TASK_SUCCESS_CNT,TASK_FAILED_CNT,LAST_UPD_TMS,MAX_RECORD_SEQ_NUM,PRNT_JOB_ID,JOB_MSG_TYP,JOB_TME_TXT,JOB_TPS_CNT,TASK_PARTIAL_CNT,TASK_FILTERED_CNT,INSTANCE_ID,PEVL_OID,JBDF_OID)
values (new_oid,null,'CLOSED  ',sysdate,sysdate,1,1,null,'EIS_SendCDFUpdateEmail',null,1,0,sysdate,0,null,null,'00:00:00',null,0,0,null,null,null);