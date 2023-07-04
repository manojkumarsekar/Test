UPDATE ft_t_extr
SET    end_tms = sysdate
WHERE  trd_id IN ( '4422-4422' )
       AND end_tms IS NULL;

UPDATE ft_t_etid
SET    end_tms = sysdate
WHERE  exec_trn_id IN ( '4422-4422' )
       AND exec_trn_id_ctxt_typ = 'BRSTRNID'
       AND end_tms IS NULL;

UPDATE ft_t_acid
SET    end_tms = sysdate
WHERE  acct_id IN (SELECT acct_id
                   FROM   ft_t_acid
                   WHERE  acct_alt_id IN ( 'TEST4422_SPLIT_S', 'TEST4422_SPLIT',
                                           'U_TT4422',
                                                   'TT12_TWD_TEST_1',
                                           'TT12_TWD_TEST', 'TT12_4422_TWD' )
                          AND end_tms IS NULL)
       AND end_tms IS NULL;

COMMIT;