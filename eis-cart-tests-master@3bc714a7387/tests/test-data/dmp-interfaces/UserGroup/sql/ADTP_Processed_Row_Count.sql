SELECT Count(1)  AS ADTP_PROCESSED_ROW_COUNT
FROM   ft_t_adtp 
WHERE  fpro_oid IN (SELECT fpro_oid 
                    FROM   ft_t_fpro 
                    WHERE  fins_pro_id_ctxt_typ = 'INTERNAL' 
                           AND fins_pro_id IN( 'test3.user3@eastspring.com', 
                                               'test4.user4@eastspring.com', 
                                               'test5.user5@eastspring.com' ))				