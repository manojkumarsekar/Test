UPDATE ft_t_extr
SET    end_tms = sysdate
WHERE  trd_id IN ( 'C1049056A', 'C1054913A' )
       AND end_tms IS NULL