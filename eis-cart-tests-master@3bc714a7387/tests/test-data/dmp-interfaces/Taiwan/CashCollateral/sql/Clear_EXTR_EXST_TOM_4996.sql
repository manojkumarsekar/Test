UPDATE ft_t_etid
    SET
        end_tms = SYSDATE
WHERE
    exec_trn_id IN (
        'C873415A','C873415B','F308533BRA','C308533BRA'
    )
    AND   exec_trn_id_ctxt_typ IN (
        'BNPTRNEVID'
    )
    AND   end_tms IS NULL;

UPDATE ft_t_extr
    SET
        end_tms = SYSDATE
WHERE
    trd_id IN (
        'C873415A','C873415B','F308533BRA','C308533BRA'
    )
    AND   end_tms IS NULL;

COMMIT;