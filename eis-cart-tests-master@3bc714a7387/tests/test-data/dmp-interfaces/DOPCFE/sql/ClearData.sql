DELETE ft_t_bhst where balh_oid in (select balh_oid from ft_t_balh
      WHERE  balh_oid IN
      (
         SELECT BALH_OID
         FROM   FT_T_BALH
         WHERE  RQSTR_ID  IN ('BRSF29')
         AND    AS_OF_TMS >= TO_DATE('${DYNAMIC_DATE}','MM/DD/YYYY')
      ));

DELETE ft_t_balh
      WHERE  balh_oid IN
      (
         SELECT BALH_OID
         FROM   FT_T_BALH
         WHERE  RQSTR_ID  IN ('BRSF29')
         AND    AS_OF_TMS >= TO_DATE('${DYNAMIC_DATE}','MM/DD/YYYY')
      );

      COMMIT