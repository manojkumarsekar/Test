DELETE ft_t_firt
WHERE
    inst_mnem IN (
        SELECT
            inst_mnem
        FROM
            ft_t_fiid
        WHERE
            fins_id IN (
                '000375',
                '001625',
                '00038A'
            )
            AND   fins_id_ctxt_typ = 'BRSISSRID'
            AND   end_tms IS NULL
    );

UPDATE ft_t_fiid
    SET
        end_tms = SYSDATE - 1,
        start_tms = SYSDATE - 1
WHERE
    fins_id IN (
        '000375',
        '001625',
        '00038A'
    )
    AND   fins_id_ctxt_typ = 'BRSISSRID'
    AND   end_tms IS NULL;