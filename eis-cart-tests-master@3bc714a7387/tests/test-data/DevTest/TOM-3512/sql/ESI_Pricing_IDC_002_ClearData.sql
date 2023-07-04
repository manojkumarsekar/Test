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
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'B3W8JF0') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'BT6C15') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'BW4W49') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'BW93R4') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VN0CP4A13040') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNTD17324045') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNBVBS170630') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNBVBS170952')
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
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'B3W8JF0') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'BT6C15') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'BW4W49') OR
        (id_ctxt_typ = 'SEDOL' AND iss_id = 'BW93R4') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VN0CP4A13040') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNTD17324045') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNBVBS170630') OR
        (id_ctxt_typ = 'ISIN' AND iss_id = 'VNBVBS170952')
    )
);
COMMIT;