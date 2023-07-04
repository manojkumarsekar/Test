DELETE
FROM ft_t_isgp
WHERE prnt_iss_grp_oid = 'RTPRCNGSOI'
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ = 'ISIN'
    AND end_tms IS NULL
    AND iss_id = 'VNBVDB173193'
);

DELETE
FROM ft_t_ispc
WHERE prc_srce_typ = 'RTVNQ'
AND prcng_meth_typ = 'REUVN'
AND prc_typ = 'BID'
AND (prc_tms BETWEEN TO_DATE('07/12/2018','MM/DD/YYYY') and TO_DATE('07/27/2018','MM/DD/YYYY')
OR ADJST_TMS>TRUNC(SYSDATE))
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ = 'ISIN'
    AND end_tms IS NULL
    AND iss_id = 'VNBVDB173193'
);

DELETE
FROM ft_t_ispc
WHERE prc_srce_typ = 'ESIVN'
AND prcng_meth_typ = 'ESIVNM'
AND prc_typ = 'DERIVE'
AND (prc_tms BETWEEN TO_DATE('07/12/2018','MM/DD/YYYY') and TO_DATE('07/27/2018','MM/DD/YYYY')
OR ADJST_TMS>TRUNC(SYSDATE))
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ = 'ISIN'
    AND end_tms IS NULL
    AND iss_id = 'VNBVDB173193'
);

COMMIT;