UPDATE FT_T_ISID set end_tms =sysdate-1, start_tms=sysdate-2
where instr_id in (select instr_id from ft_T_ISID where iss_id='${Security_ID}')
and id_ctxt_typ IN ('${ID_CTXT_TYPE}')
AND END_TMS IS NULL
AND  LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY';

UPDATE FT_T_ETID ETID set end_tms =sysdate-1, start_tms=sysdate-2
where ETID.EXEC_TRn_ID  IN (select EXEC_TRN_ID from ft_t_etid where EXEC_TRN_ID ='${TRD_ID}' and EXEC_TRN_ID_CTXT_TYP = 'LBUTRNID')
and  ETID.EXEC_TRN_ID_CTXT_TYP = 'LBUTRNID'
AND  ETID.END_TMS IS NULL
AND  LAST_CHG_USR_ID='EIS_RCRLBU_DMP_TRANSACTION';


COMMIT