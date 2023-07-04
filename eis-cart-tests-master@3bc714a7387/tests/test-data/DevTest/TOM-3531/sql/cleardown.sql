DELETE ft_t_wtrd WHERE rptg_prd_end_dte = LAST_DAY(TRUNC(SYSDATE));

COMMIT;