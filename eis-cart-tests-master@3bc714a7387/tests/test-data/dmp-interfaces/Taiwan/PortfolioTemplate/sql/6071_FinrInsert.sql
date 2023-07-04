Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CROSS_REF_ID,START_TMS,FINSRL_NME,DATA_STAT_TYP)
 (SELECT INST_MNEM,'SBINVMGR',SYSDATE,'EIS:CSTM',new_oid,START_TMS,'EASTSPRING INVESTMENTS LIMITED','ACTIVE'
        FROM ft_T_fiid fiid
        where fins_id = 'ESI' and FINS_ID_CTXT_TYP = 'INHOUSE' and end_tms is null
        and not exists
        (select 1 from ft_t_finr where fiid.inst_mnem = inst_mnem and finsrl_typ = 'SBINVMGR')
  );

Insert into FT_T_FINR (INST_MNEM,FINSRL_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,CROSS_REF_ID,START_TMS,DATA_STAT_TYP)
 (SELECT INST_MNEM,'SUBCUST',SYSDATE,'EIS:CSTM',new_oid,START_TMS,'ACTIVE'
        FROM ft_T_fiid fiid
        where fins_id = 'ES-SG' and FINS_ID_CTXT_TYP = 'INHOUSE' and end_tms is null
        and not exists
        (select 1 from ft_t_finr where fiid.inst_mnem = inst_mnem and finsrl_typ = 'SUBCUST')
  );

COMMIT;