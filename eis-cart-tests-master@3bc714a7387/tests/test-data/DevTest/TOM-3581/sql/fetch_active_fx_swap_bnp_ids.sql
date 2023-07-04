SELECT MIN(iss_id) REC_LEG_BNP_ID, MAX(iss_id) PAY_LEG_BNP_ID
FROM   (
         SELECT instr_id
         FROM   (
                  SELECT issu.instr_id, issu.start_tms
                  FROM   ft_t_isid isid, ft_t_iscl iscl, ft_t_isgu isgu, ft_t_issu issu
                  WHERE  isid.id_ctxt_typ = 'BNPLSTID'
                  AND    isid.end_tms IS NULL
                  AND    iscl.instr_id = isid.instr_id
                  AND    iscl.indus_cl_set_id = 'BNPSECTYPE'
                  AND    iscl.cl_value = 'BVSBXXXXXU'
                  AND    iscl.end_tms IS NULL
                  AND    isgu.instr_id = isid.instr_id
                  AND    isgu.gu_typ = 'COUNTRY'
                  AND    isgu.iss_gu_purp_typ = 'ISSUANCE'
                  AND    isgu.gu_id = 'US'
                  AND    isgu.end_tms IS NULL
                  AND    issu.instr_id = isid.instr_id
                  AND    issu.denom_curr_cde = 'USD'
                  AND    issu.pref_iss_nme LIKE '%HKD%'
                  GROUP BY issu.instr_id, issu.start_tms
                  HAVING COUNT(DISTINCT isid.iss_id) = 2
                  ORDER BY issu.start_tms DESC
                )
         WHERE  ROWNUM = 1
       ) x,
       ft_t_isid isid
WHERE  isid.instr_id = x.instr_id
AND    isid.id_ctxt_typ = 'BNPLSTID'
AND    isid.end_tms IS NULL
GROUP BY isid.instr_id