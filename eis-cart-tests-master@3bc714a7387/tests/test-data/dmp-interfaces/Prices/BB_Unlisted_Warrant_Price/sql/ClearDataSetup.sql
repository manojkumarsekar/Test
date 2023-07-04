DELETE FROM gs_gc.ft_t_ispc
WHERE  last_chg_tms > Trunc(sysdate)
       AND instr_id IN (SELECT instr_id
                        FROM   gs_gc.ft_t_isid
                        WHERE  iss_id  ='SBTKFJD34'
                               AND id_ctxt_typ = 'BCUSIP'
                               AND end_tms IS NULL);

DELETE FROM gs_gc.ft_t_ispc
WHERE  last_chg_tms > Trunc(sysdate)
       AND instr_id IN (SELECT instr_id
                        FROM   gs_gc.ft_t_isid
                        WHERE  iss_id  ='BES2XRRY6'
                               AND id_ctxt_typ = 'BCUSIP'
                               AND end_tms IS NULL);


INSERT INTO ft_t_isgp
(SELECT (SELECT iss_grp_oid
         FROM   ft_t_isgr
         WHERE  iss_grp_id = 'UNLWARSOI'
                AND end_tms IS NULL),
        SYSDATE,
        NULL,
        instr_id,
        SYSDATE,
        'EIS:CSTM',
        'MEMBER',
        NULL,
        NULL,
        NULL,
        NULL,
        'ACTIVE',
        'Unlisted Warrant Pricing',
        NULL,
        NULL,
        NULL,
        NULL,
        new_oid,
        NULL
 FROM   ft_t_isid
 WHERE  id_ctxt_typ = 'BCUSIP'
        AND iss_id IN ( 'BES2XRRY6')
        AND end_tms IS NULL);

COMMIT