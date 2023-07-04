DELETE FROM ft_t_ismc
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id IN ( 'SBRJFWP37', 'BRSU9DTQ8', 'G2519Y108', '056752AM0', '73928RAA4' )
                           AND id_ctxt_typ = 'BCUSIP');

COMMIT;