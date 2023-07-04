UPDATE ft_t_accr SET end_tms = sysdate WHERE rl_typ='DOPAPPRT' and end_tms is null and acct_id in
(select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null);

UPDATE ft_t_fnvd SET end_tms=sysdate WHERE end_tms is null and fnvs_oid in (select fnvs_oid from ft_t_fnvs where end_tms is null and
fnch_oid in (select fnch_oid from ft_t_fnch where end_tms is null and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null)));

UPDATE ft_t_fnvs SET end_tms=sysdate WHERE end_tms is null and fnch_oid in (select fnch_oid from ft_t_fnch where end_tms is null
and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='AGSACA' and acct_id_ctxt_typ='CRTSID' and end_tms is null));

UPDATE ft_t_abmr SET end_tms=sysdate where rl_typ='DRFTBNCH' and end_tms is null and 
acct_id in (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='AGSACA' AND ACCT_ID_CTXT_TYP='CRTSID' and end_tms is null)