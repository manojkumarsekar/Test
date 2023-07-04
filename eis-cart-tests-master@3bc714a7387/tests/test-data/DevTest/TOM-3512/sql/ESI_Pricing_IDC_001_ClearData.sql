DELETE
FROM ft_t_isgp
WHERE prnt_iss_grp_oid = 'IDCPRCGSOI'
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ  in ('SEDOL', 'ISIN')
    AND end_tms IS NULL
    AND
    (
        (id_ctxt_typ = 'SEDOL' AND iss_id = '6BQ56C4') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'B3YH4S3') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNBVBS164062') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNTD16314633')
    )
);
DELETE
FROM ft_t_ispc
WHERE prc_srce_typ = 'IDCVN'
AND prcng_meth_typ = 'ESILOCAL'
AND prc_typ = 'BID'
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ  in ('SEDOL', 'ISIN')
    AND end_tms IS NULL
    AND
    (
        (id_ctxt_typ = 'SEDOL' AND iss_id = '6BQ56C4') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'B3YH4S3') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNBVBS164062') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNTD16314633')
    )
);
COMMIT;