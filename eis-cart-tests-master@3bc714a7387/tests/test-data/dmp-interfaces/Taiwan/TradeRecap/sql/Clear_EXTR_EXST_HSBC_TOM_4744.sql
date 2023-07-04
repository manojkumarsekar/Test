UPDATE ft_t_etid
    SET
        end_tms = SYSDATE
WHERE
    exec_trn_id IN (
        '4744-4722',
        '4744-4716_Index',
        '4744-4716_Cust',
        '4744-302',
        '4744-303',
        '4744-304',
        '4744-2776_valid_trade_parent',
        '4744-401a_AT',
        '4744-402a_AT',
        '4744-403a_AT',
        '4744-01',
        '4744-02',
        '4744-03',
        '4744-04',
        '4744-05',
        '4744-06',
        '4744-07',
        '4744-08',
        '4744-CP01',        
        '4744-09'
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
            AND   brsnum.exec_trn_id in ('4744-02','4744-08','4744-05','4744-07','4744-CP01')
            AND   brsnum.exec_trn_id_ctxt_typ = 'BRSTRNID'
    );

UPDATE ft_t_extr
    SET
        end_tms = SYSDATE
WHERE
    trd_id IN (
        '4744-4722',
        '4744-4716_Index',
        '4744-4716_Cust',
        '4744-302',
        '4744-303',
        '4744-304',
        '4744-2776_valid_trade_parent',
        '4744-401a_AT',
        '4744-402a_AT',
        '4744-403a_AT',
        '4744-01',
        '4744-02',
        '4744-03',
        '4744-04',
        '4744-05',
        '4744-06',
        '4744-07',
				'4744-CP01',
        '4744-08',
        '4744-09'
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