UPDATE ft_t_extr
SET    end_tms = sysdate
WHERE  trd_id IN ( '4298-4298','TEST4298-TEST4298','3503-125' )
       AND end_tms IS NULL;

UPDATE ft_t_etid
SET    end_tms = sysdate
WHERE  exec_trn_id IN ( '4298-4298','TEST4298-TEST4298','3503-125' )
       AND exec_trn_id_ctxt_typ = 'BRSTRNID'
       AND end_tms IS NULL;

UPDATE ft_t_acid
SET    end_tms = sysdate
WHERE  acct_id IN (SELECT acct_id
                   FROM   ft_t_acid
                   WHERE  acct_alt_id IN ( 'TEST4298_SPLIT_S', 'TEST4298_SPLIT',
                                           'U_TT4298')
                          AND end_tms IS NULL)
       AND end_tms IS NULL;

COMMIT;