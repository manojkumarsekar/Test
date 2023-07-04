DELETE FROM ft_t_etmg WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('TST101','TST102','TST103'));
DELETE FROM ft_t_etid WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('TST101','TST102','TST103'));
DELETE FROM ft_t_exst WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('TST101','TST102','TST103'));
DELETE FROM ft_t_ttrl WHERE prnt_exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('TST101','TST102','TST103'));
DELETE FROM ft_t_extr WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('TST101','TST102','TST103'));
COMMIT;