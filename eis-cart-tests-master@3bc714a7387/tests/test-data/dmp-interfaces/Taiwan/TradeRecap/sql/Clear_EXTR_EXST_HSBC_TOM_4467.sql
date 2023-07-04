UPDATE ft_t_etid
    SET
        end_tms = SYSDATE
WHERE
    exec_trn_id IN (
        '4467-4722',
        '4467-4716_Index',
        '4467-4716_Cust',
        '4467-302_C',
        '4467-302',
        '4467-303',
        '4467-304',
        '4467-TD01',
        '4467-2776_valid_trade_parent'
    )
    AND   exec_trn_id_ctxt_typ = 'BRSTRNID'
    AND   end_tms IS NULL;

UPDATE ft_t_extr
    SET
        end_tms = SYSDATE
WHERE
    trd_id IN (
        '4467-4722',
        '4467-4716_Index',
        '4467-4716_Cust',
        '4467-302_C',
        '4467-302',
        '4467-303',
        '4467-304',
        '4467-TD01',
        '4467-2776_valid_trade_parent'
    )
    AND   end_tms IS NULL;

UPDATE ft_t_acid
    SET
        end_tms = SYSDATE
WHERE
    acct_id IN (
        SELECT
            acct_id
        FROM
            ft_t_acid
        WHERE
            acct_alt_id IN (
                'TW-MAIN-SITCA-1',
                'TW-MAIN-SITCA-2'
            )
            AND   end_tms IS NULL
    );


COMMIT;