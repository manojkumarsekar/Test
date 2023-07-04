DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy'));

DELETE ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','mm/dd/yyyy');