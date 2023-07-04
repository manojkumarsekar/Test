UPDATE ft_t_accl
SET    end_tms = NULL, last_chg_usr_id = REPLACE(last_chg_usr_id, ' 6623-cetrelpersecurity')
WHERE  indus_cl_set_id = 'FNDPLTFM'
       AND cl_value IN( 'F', 'S' )
       AND last_chg_usr_id LIKE '%6623-cetrelpersecurity'
       AND end_tms >= Trunc(sysdate-1)
       AND acct_id NOT IN (SELECT acct_id
                           FROM   ft_t_acid
                           WHERE  acct_alt_id IN ( 'ESP4053500', 'ESP4886960',
                                                   'ESP3307604', 'ESP3159844',
                                                   'ESP1928362', 'ESP5109532' )
                                  AND acct_id_ctxt_typ = 'EISPRTID');