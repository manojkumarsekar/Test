DELETE FROM gs_gc.ft_t_isps
WHERE  iss_prc_id IN (SELECT iss_prc_id
                      FROM   gs_gc.ft_t_ispc
                      WHERE  last_chg_tms > Trunc(sysdate)
                             AND instr_id IN (SELECT instr_id
                                              FROM   gs_gc.ft_t_isid
                                              WHERE  iss_id IN ( 'LU0440258258',
                                                                 'GB0030932452',
                                                                 'GB00F75H9F84',
                                                                 'IE00B19Z9505'
                                                               )
                                                     AND id_ctxt_typ = 'ISIN'
                                                     AND end_tms IS NULL));

DELETE FROM gs_gc.ft_t_isps
WHERE  ref_iss_prc_id IN (SELECT iss_prc_id
                          FROM   gs_gc.ft_t_ispc
                          WHERE  last_chg_tms > Trunc(sysdate)
                                 AND instr_id IN (SELECT instr_id
                                                  FROM   gs_gc.ft_t_isid
                                                  WHERE
                                     iss_id IN ( 'LU0440258258',
                                                 'GB0030932452',
                                                 'GB00F75H9F84',
                                                 'IE00B19Z9505' )
                                     AND id_ctxt_typ = 'ISIN'
                                     AND end_tms IS NULL));

DELETE FROM gs_gc.ft_t_gpcs
WHERE  iss_prc_id IN (SELECT iss_prc_id
                      FROM   gs_gc.ft_t_ispc
                      WHERE  last_chg_tms > Trunc(sysdate)
                             AND instr_id IN (SELECT instr_id
                                              FROM   gs_gc.ft_t_isid
                                              WHERE  iss_id IN ( 'LU0440258258',
                                                                 'GB0030932452',
                                                                 'GB00F75H9F84',
                                                                 'IE00B19Z9505'
                                                               )
                                                     AND id_ctxt_typ = 'ISIN'
                                                     AND end_tms IS NULL));

DELETE FROM gs_gc.ft_t_ispc
WHERE  last_chg_tms > Trunc(sysdate)
       AND instr_id IN (SELECT instr_id
                        FROM   gs_gc.ft_t_isid
                        WHERE  iss_id IN ( 'LU0440258258', 'GB0030932452',
                                           'GB00F75H9F84',
                                           'IE00B19Z9505' )
                               AND id_ctxt_typ = 'ISIN'
                               AND end_tms IS NULL);

UPDATE ft_t_isgp
SET    end_tms = NULL
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  id_ctxt_typ = 'ISIN'
                           AND iss_id = 'GB0030932452')
       AND part_curr_cde = 'GBP';

COMMIT;