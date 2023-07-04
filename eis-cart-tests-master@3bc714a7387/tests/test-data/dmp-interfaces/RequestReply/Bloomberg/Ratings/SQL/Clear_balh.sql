DELETE ft_t_bhst
WHERE  balh_oid IN
(
SELECT BALH.BALH_OID
FROM   FT_T_BALH BALH
WHERE balh.AS_OF_TMS >=to_date('${T_MMDDYYYY}','MM/DD/YYYY')
);

DELETE ft_t_balh
WHERE  balh_oid IN
(
   SELECT BALH.BALH_OID
   FROM   FT_T_BALH BALH
   WHERE balh.AS_OF_TMS >=to_date('${T_MMDDYYYY}','MM/DD/YYYY')
);