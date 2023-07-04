DELETE FROM ft_t_etmg WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('229639','229640','229674','229691','224122','224123'));
DELETE FROM ft_t_etid WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('229639','229640','229674','229691','224122','224123'));
DELETE FROM ft_t_exst WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('229639','229640','229674','229691','224122','224123'));
DELETE FROM ft_t_ttrl WHERE prnt_exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('229639','229640','229674','229691','224122','224123'));
DELETE FROM ft_t_extr WHERE exec_trd_id in (SELECT exec_trd_id FROM ft_t_etid WHERE exec_trn_id_ctxt_typ='BRSTRNID' AND exec_trn_id IN ('229639','229640','229674','229691','224122','224123'));
COMMIT;