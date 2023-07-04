DELETE ft_t_firt
WHERE
    inst_mnem IN (
        SELECT
            inst_mnem
        FROM
            ft_t_fiid
        WHERE
            fins_id IN (
                'TEST_3968',
                'TEST_3968_1',
                'TEST_3968_2'
            )
    )
    AND   rtng_set_oid IN (
        'TRCMIRLR==',
        'TRCMIRSR=='
    );

DELETE ft_t_fiid
WHERE
    fins_id IN (
        'TEST_3968',
        'TEST_3968_1',
        'TEST_3968_2'
    );

COMMIT;