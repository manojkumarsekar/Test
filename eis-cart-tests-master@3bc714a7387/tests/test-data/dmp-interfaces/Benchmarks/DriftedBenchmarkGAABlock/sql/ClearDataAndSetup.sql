DELETE
FROM ft_t_bnvc
WHERE bnvl_oid IN
(
    SELECT bnvl.bnvl_oid
        FROM ft_t_bnvl bnvl where TRUNC(bnvl.bnchmrk_val_tms) >= trunc(sysdate - 3)
);

DELETE
FROM ft_t_bnvl bnvl
WHERE TRUNC(bnvl.bnchmrk_val_tms) >= trunc(sysdate - 3);

UPDATE FT_T_ISID set end_tms=SYSDATE-1 where ID_CTXT_TYP='BRSBNCHISSUID' and ISS_ID like 'AA_MOD_DERTEST%' and end_tms is null;

DELETE FROM FT_T_BNCM where CMNT_REAS_TYP = 'BNCHCNSTINT' AND TRUNC(CMNT_TMS) >= trunc(sysdate - 5);

UPDATE FT_T_BNID SET bnchmrk_id='MP_TESTDOP' where bnchmrk_id='SNP500TD' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
UPDATE FT_T_BNID SET bnchmrk_id='SAA_TESTDOP' where bnchmrk_id='EMBIGIDRUS' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;

Insert into FT_T_ABMR (ABMR_OID,ORG_ID,BK_ID,ACCT_ID,BNCH_OID,RL_TYP,START_TMS,END_TMS,LAST_CHG_USR_ID,LAST_CHG_TMS,RL_DESC,PART_CAMT,PART_CURR_CDE,PART_CPCT,DATA_STAT_TYP,DATA_SRC_ID)
SELECT NEW_OID, 'EIS','EIS', (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='ASPRAB' AND ACCT_ID_CTXT_TYP='CRTSID' and end_tms is null),
(select bnch_oid from ft_t_BNID where BNCHMRK_ID_CTXT_TYP='BRSBNCHID' and BNCHMRK_ID='SAA_TESTDOP' and end_tms is null),
'DRFTBNCH', SYSDATE, null, 'EIS:CSTM', SYSDATE,null,null,null,null,'ACTIVE','EIS' FROM DUAL
where not exists (select 1 from ft_t_abmr where acct_id=(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='ASPRAB' AND ACCT_ID_CTXT_TYP='CRTSID' and end_tms is null)
and bnch_oid=(select bnch_oid from ft_t_BNID where BNCHMRK_ID_CTXT_TYP='BRSBNCHID' and BNCHMRK_ID='SAA_TESTDOP' and end_tms is null) and rl_typ='DRFTBNCH');

update ft_t_bnch set BASE_CURR_CDE = 'TWD' where bnch_oid in (select bnch_oid from ft_t_BNID where BNCHMRK_ID_CTXT_TYP='BRSBNCHID' and BNCHMRK_ID='SAA_TESTDOP' and end_tms is null);

COMMIT;