UPDATE ft_t_etid
    SET
        end_tms = SYSDATE
WHERE
    exec_trn_id IN (
        '4468-4722',
        '4468-4716_Index',
        '4468-4716_Cust',
        '4468-302',
        '4468-303',
        '4468-304',
        '4468-2776_valid_trade_parent',
        '4468-401a_AT',
        '4468-402a_AT',
        '4468-403a_AT',
        '4468-01',
        '4468-02',
        '4468-03',
        '4468-04',
        '4468-05',
        '4468-06',
        '4468-07',
        '4468-08',
        '4468-09',
        '4468-FX01',
        '4468-4468'
    )
    AND   exec_trn_id_ctxt_typ IN (
        'BRSTRNID'
    )
    AND   end_tms IS NULL;


DELETE ft_t_etid
WHERE
    etid_oid IN (
        SELECT
            trdnum.etid_oid
        FROM
            ft_t_etid trdnum,
            ft_t_etid brsnum
        WHERE
            trdnum.exec_trn_id in ('1983','1984','1985','1986')
            AND   trdnum.exec_trn_id_ctxt_typ = 'BRSTRADENUM'
            AND   trdnum.exec_trd_id = brsnum.exec_trd_id
            AND   brsnum.exec_trn_id in (
        '4468-4722',
        '4468-4716_Index',
        '4468-4716_Cust',
        '4468-302',
        '4468-303',
        '4468-304',
        '4468-2776_valid_trade_parent',
        '4468-401a_AT',
        '4468-402a_AT',
        '4468-403a_AT',
        '4468-01',
        '4468-02',
        '4468-03',
        '4468-04',
        '4468-05',
        '4468-06',
        '4468-07',
        '4468-08',
        '4468-09',
        '4468-FX01',        
        '4468-4468'
    )
            AND   brsnum.exec_trn_id_ctxt_typ = 'BRSTRNID'
    );

UPDATE ft_t_extr
    SET
        end_tms = SYSDATE
WHERE
    trd_id IN (
        '4468-4722',
        '4468-4716_Index',
        '4468-4716_Cust',
        '4468-302',
        '4468-303',
        '4468-304',
        '4468-2776_valid_trade_parent',
        '4468-401a_AT',
        '4468-402a_AT',
        '4468-403a_AT',
        '4468-01',
        '4468-02',
        '4468-03',
        '4468-04',
        '4468-05',
        '4468-06',
        '4468-07',
        '4468-08',
        '4468-09',
        '4468-FX01',        
        '4468-4468'
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
                'TSTTT56','TSTTT56_S','TSTTT56_TWD','TSTTT16','TSTTT16_TWD'
            )
            AND   end_tms IS NULL
    );

COMMIT;