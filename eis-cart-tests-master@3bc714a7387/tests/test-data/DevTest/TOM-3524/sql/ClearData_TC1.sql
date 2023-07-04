DELETE
FROM ft_t_isrt
WHERE rtng_cde IN ('alpha', 'beta')
AND rtng_set_oid =
(
    SELECT rtng_set_oid
    FROM ft_t_rtng
    WHERE rtng_set_mnem = 'CMPHKRTG'
    AND end_tms IS NULL
);

DELETE
FROM ft_t_rtvl
WHERE rtng_cde IN ('alpha', 'beta')
AND rtng_set_oid =
(
    SELECT rtng_set_oid
    FROM ft_t_rtng
    WHERE rtng_set_mnem = 'CMPHKRTG'
    AND end_tms IS NULL
) AND end_tms IS NULL;

COMMIT;