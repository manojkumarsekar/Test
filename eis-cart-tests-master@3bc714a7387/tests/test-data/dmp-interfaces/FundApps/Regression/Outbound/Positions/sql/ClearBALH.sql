DELETE ft_t_bhst where balh_oid in (select balh_oid from ft_t_balh
      WHERE  balh_oid IN
      (
         SELECT BALH_OID
         FROM   FT_T_BALH
         WHERE  RQSTR_ID  IN ('MNGEOD','BOCIEOD','ESJPEOD','KOREAEOD','TMBAMEOD','EISEOD','PPMEOD','WFOEEOD','EISEOD','ESGAEOD','BRSEOD','ROBOCOLL')
         AND    AS_OF_TMS >= TO_DATE('${CURR_DATE}','DD/MM/YYYY')
      ));

DELETE ft_t_balh
      WHERE  balh_oid IN
      (
         SELECT BALH_OID
         FROM   FT_T_BALH
         WHERE  RQSTR_ID  IN ('MNGEOD','BOCIEOD','ESJPEOD','KOREAEOD','TMBAMEOD','EISEOD','PPMEOD','WFOEEOD','EISEOD','ESGAEOD','BRSEOD','ROBOCOLL')
         AND    AS_OF_TMS >= TO_DATE('${CURR_DATE}','DD/MM/YYYY')
      );

      COMMIT