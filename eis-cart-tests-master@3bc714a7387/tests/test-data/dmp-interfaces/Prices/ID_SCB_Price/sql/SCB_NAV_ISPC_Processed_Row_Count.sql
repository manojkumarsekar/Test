SELECT COUNT(1) PROCESSED_ROW_COUNT
FROM   ft_t_ispc
WHERE  prcng_meth_typ = 'ESIIDN'
       AND prc_qt_meth_typ = 'PRCQUOTE'
       AND prc_srce_typ = 'ESIDN'
       AND Trunc(prc_tms) = Trunc(sysdate)
       AND prc_typ = 'CLOSE'
       AND prc_valid_typ = 'CHECKED'
       AND Trunc(adjst_tms) = Trunc(sysdate)
       AND instr_id IN (SELECT issu.instr_id
                        FROM   ft_t_isid isid
                               INNER JOIN ft_t_issu issu
                                       ON issu.instr_id = isid.instr_id
                               INNER JOIN ft_t_aisr aisr
                                       ON aisr.instr_id = issu.instr_id
                               INNER JOIN ft_t_acid acid
                                       ON acid.acct_id = aisr.acct_id
                        WHERE  isid.id_ctxt_typ = 'EISLSTID'
                               AND aisr.acct_issu_rl_typ = 'AUT'
                               AND acid.acct_id_ctxt_typ = 'SCBFUNDID'
                               AND acid.acct_alt_id IN (   'EII01DFCNADDMF00',
                                                           'EII01DFSADPSEF00',
                                                           'EII01DFSADPSFF00',
                                                           'EII01DFCNADRCF00' ))