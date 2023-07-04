DELETE FROM ft_t_exst
WHERE  exec_trd_id IN (SELECT exec_trd_id
                       FROM   ft_t_extr
                       WHERE
       trd_legend_txt = 'TOM-3500 TICKET AUTOMATED TESTING');

DELETE FROM ft_t_etmg
WHERE  exec_trd_id IN (SELECT exec_trd_id
                       FROM   ft_t_extr
                       WHERE
       trd_legend_txt = 'TOM-3500 TICKET AUTOMATED TESTING');

DELETE FROM ft_t_extr
WHERE  trd_legend_txt = 'TOM-3500 TICKET AUTOMATED TESTING';

COMMIT;