SELECT
    COUNT(1) AS PROCESSED_ROW_COUNT
FROM
    ft_t_extr extr
    INNER JOIN ft_t_etmg etmg ON extr.exec_trd_id = etmg.exec_trd_id
    INNER JOIN ft_t_etid etid ON extr.exec_trd_id = etid.exec_trd_id
WHERE
    trn_cde = 'TWFASCASHTXN'
    AND   trunc(extr.last_chg_tms) = trunc(SYSDATE)
