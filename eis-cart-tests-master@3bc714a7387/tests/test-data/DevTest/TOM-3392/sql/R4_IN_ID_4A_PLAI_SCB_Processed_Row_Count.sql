   SELECT Count(1) AS PROCESSED_ROW_COUNT
             FROM   ft_t_extr extr
                    inner join ft_t_exst etmg
                            ON extr.exec_trd_id = etmg.exec_trd_id
                    inner join ft_t_exst exst
                            ON extr.exec_trd_id = exst.exec_trd_id
                    inner join ft_t_etid etid
                            ON extr.exec_trd_id = etid.exec_trd_id
             WHERE  trn_cde = 'ESIICASHTXN'
                    AND Trunc(extr.last_chg_tms) = Trunc(SYSDATE)