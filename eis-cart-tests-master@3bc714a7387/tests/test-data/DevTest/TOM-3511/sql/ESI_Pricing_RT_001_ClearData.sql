DELETE
FROM ft_t_isgp
WHERE prnt_iss_grp_oid = 'RTPRCNGSOI'
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ = 'ISIN'
    AND end_tms IS NULL
    AND iss_id IN
    (
        'VNTB13281548',
        'VNTD10200655',
        'VNTD15302894',
        'VNTD16214460',
        'VNTD16314617',
        'VNTD17474097'
    )
);

DELETE
FROM ft_t_ispc
WHERE prc_srce_typ = 'RTVNQ'
AND prcng_meth_typ = 'REUVN'
AND (prc_tms BETWEEN TO_DATE('07/12/2018','MM/DD/YYYY') and TO_DATE('07/27/2018','MM/DD/YYYY')
OR ADJST_TMS>TRUNC(SYSDATE))
AND prc_typ = 'BID'
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ = 'ISIN'
    AND end_tms IS NULL
    AND iss_id IN
    (
        'VNTB13281548',
        'VNTD10200655',
        'VNTD15302894',
        'VNTD16214460',
        'VNTD16314617',
        'VNTD17474097'
    )
);

DELETE
FROM ft_t_ispc
WHERE prc_srce_typ = 'ESIVN'
AND (prc_tms BETWEEN TO_DATE('07/12/2018','MM/DD/YYYY') and TO_DATE('07/27/2018','MM/DD/YYYY')
OR ADJST_TMS>TRUNC(SYSDATE))
AND prcng_meth_typ = 'ESIVNM'
AND prc_typ = 'DERIVE'
AND instr_id IN
(
    SELECT instr_id
    FROM ft_t_isid
    WHERE id_ctxt_typ = 'ISIN'
    AND end_tms IS NULL
    AND iss_id IN
    (
        'VNTB13281548',
        'VNTD10200655',
        'VNTD15302894',
        'VNTD16214460',
        'VNTD16314617',
        'VNTD17474097'
    )
);

COMMIT;