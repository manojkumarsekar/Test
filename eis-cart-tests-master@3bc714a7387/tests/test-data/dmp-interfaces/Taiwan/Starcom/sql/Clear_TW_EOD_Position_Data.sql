DELETE FROM ft_t_balh
WHERE  Trunc(as_of_tms) = Trunc(SYSDATE)
       AND acct_id IN(SELECT DISTINCT acct_id
                      FROM   ft_t_acid
                      WHERE  acct_alt_id IN( '${PORTFOLIO_ID_2}','${PORTFOLIO_ID_1}','TT37_S' ))
       AND isid_oid IN(SELECT DISTINCT isid_oid
                       FROM   ft_t_isid
                       WHERE  iss_id IN( 'BRTDW7S34', 'BRSSGGVD4', 'BPM1CTXP0',
                                         'CSHHSBTH9'
                                         ,
                                         'BPM227JV0', 'BPM1CVCN3', 'S63485445',
                                         'BPM1EFK80'
                                         ,
                                         'SBD5CPS45','1248EPCE1' ));
COMMIT;