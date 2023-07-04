DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms >= TRUNC(SYSDATE) + 1);

DELETE ft_t_balh WHERE as_of_tms >= TRUNC(SYSDATE) + 1;

DELETE ft_t_fxrt WHERE TRUNC(fx_tms) >= TRUNC(SYSDATE) + 1;

COMMIT;