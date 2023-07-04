SELECT x.instr_id AS INSTR_ID,
       i.iss_id   AS ISIN,
       s.iss_id   AS SEDOL,
       b.iss_id   AS BCUSIP,
       e.iss_id   AS EISLSTID,
       r.iss_id   AS RIC
FROM   ft_t_ista x,
       ft_t_isid i,
       ft_t_isid s,
       ft_t_isid b,
       ft_t_isid e,
       ft_t_isid r
WHERE  x.iss_stat_typ = 'DEL'
AND    i.instr_id = x.instr_id
AND    i.id_ctxt_typ = 'ISIN'
AND    i.end_tms IS NULL
AND    s.instr_id = x.instr_id
AND    s.id_ctxt_typ = 'SEDOL'
AND    s.end_tms IS NULL
AND    b.instr_id = x.instr_id
AND    b.id_ctxt_typ = 'BCUSIP'
AND    b.end_tms IS NULL
AND    e.instr_id = x.instr_id
AND    e.id_ctxt_typ = 'EISLSTID'
AND    e.end_tms IS NULL
AND    r.instr_id = x.instr_id
AND    r.id_ctxt_typ = 'RIC'
AND    r.end_tms IS NULL
AND    ROWNUM = 1