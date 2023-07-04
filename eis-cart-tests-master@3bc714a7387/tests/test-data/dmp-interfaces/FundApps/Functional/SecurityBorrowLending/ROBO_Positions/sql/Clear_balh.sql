DELETE ft_t_bhst
WHERE  balh_oid IN
(
SELECT BALH.BALH_OID
FROM   FT_T_BALH BALH
where balh.ADJST_TMS >=sysdate-5
AND    balh.AS_OF_TMS >=sysdate-5
AND RQSTR_ID like 'ROBO%'
);

DELETE ft_t_balh
WHERE  balh_oid IN
(
   SELECT BALH.BALH_OID
   FROM   FT_T_BALH BALH
    where balh.ADJST_TMS >=sysdate-5
   AND    balh.AS_OF_TMS >=sysdate-5
   AND RQSTR_ID like 'ROBO%'
);
COMMIT;