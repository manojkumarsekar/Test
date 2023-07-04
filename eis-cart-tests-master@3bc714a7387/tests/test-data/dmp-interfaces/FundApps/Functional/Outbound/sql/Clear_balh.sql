
DELETE ft_t_bhst
WHERE  balh_oid IN
(
SELECT BALH.BALH_OID
FROM   FT_T_BALH BALH
where balh.ADJST_TMS >=sysdate-1
AND    balh.AS_OF_TMS >=sysdate-1
);

DELETE ft_t_balh
WHERE  balh_oid IN
(
   SELECT BALH.BALH_OID
   FROM   FT_T_BALH BALH
    where balh.ADJST_TMS >=sysdate-1
   AND    balh.AS_OF_TMS >=sysdate-1
);