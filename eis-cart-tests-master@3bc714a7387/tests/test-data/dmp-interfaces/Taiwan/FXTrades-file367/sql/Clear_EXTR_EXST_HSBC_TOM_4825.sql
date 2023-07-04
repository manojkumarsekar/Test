UPDATE ft_t_etid
    SET
        end_tms = SYSDATE
WHERE
    exec_trn_id IN (
        '4825-4825'
    )
    AND   exec_trn_id_ctxt_typ = 'BRSTRNID'
    AND   end_tms IS NULL;

UPDATE ft_t_extr
    SET
        end_tms = SYSDATE
WHERE
    trd_id IN (
        '4825-4825'
    )
    AND   end_tms IS NULL;

COMMIT;