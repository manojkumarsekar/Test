UPDATE ft_t_idmv
SET intrnl_dmn_val_txt = '0.0005' -- set both SOD and EOD Tolerance to 0.0005
WHERE
(
    (intrnl_dmn_val_nme = 'DRIFTED_BM_SOD_WGT_TOLERANCE' AND fld_id = '41000803') OR
    (intrnl_dmn_val_nme = 'DRIFTED_BM_EOD_WGT_TOLERANCE' AND fld_id = '41000804')
);

DELETE
FROM ft_t_bnvc
WHERE bnvl_oid IN
(
    SELECT bnvl.bnvl_oid
    FROM ft_t_bnch bnch
        INNER JOIN ft_t_bnpt bnpt
            ON bnpt.prnt_bnch_oid = bnch.bnch_oid
                AND bnch.end_tms IS NULL
                AND bnpt.end_tms IS NULL
        INNER JOIN ft_t_bnvl bnvl
            ON bnvl.bnpt_oid = bnpt.bnpt_oid
                AND bnvl.bnchmrk_val_tms >= trunc(sysdate) - 2
        INNER JOIN ft_t_bnid bnid
            ON bnid.bnch_oid = bnch.bnch_oid
                AND bnid.end_tms IS NULL
                AND bnid.bnchmrk_id_ctxt_typ = 'BRSBNCHID'
                AND substr(bnid.bnchmrk_id, 0, 3) = 'GMP'
                AND bnid.bnchmrk_id IN ('GMP_ABTSLF', 'GMP_AHOBI6', 'GMP_AHOBIN', 'GMP_AHOBLF', 'GMP_AHOHKD', 'GMP_AHOPGH')
);

DELETE
FROM ft_t_bnvl
WHERE bnvl_oid IN
(
    SELECT bnvl.bnvl_oid
    FROM ft_t_bnch bnch
        INNER JOIN ft_t_bnpt bnpt
            ON bnpt.prnt_bnch_oid = bnch.bnch_oid
                AND bnch.end_tms IS NULL
                AND bnpt.end_tms IS NULL
        INNER JOIN ft_t_bnvl bnvl
            ON bnvl.bnpt_oid = bnpt.bnpt_oid
                AND bnvl.bnchmrk_val_tms >= trunc(sysdate) - 2
        INNER JOIN ft_t_bnid bnid
            ON bnid.bnch_oid = bnch.bnch_oid
                AND bnid.end_tms IS NULL
                AND bnid.bnchmrk_id_ctxt_typ = 'BRSBNCHID'
                AND substr(bnid.bnchmrk_id, 0, 3) = 'GMP'
                AND bnid.bnchmrk_id IN ('GMP_ABTSLF', 'GMP_AHOBI6', 'GMP_AHOBIN', 'GMP_AHOBLF', 'GMP_AHOHKD', 'GMP_AHOPGH')
);

DELETE
FROM ft_cfg_sbex
WHERE sbex_oid =
(
    SELECT MAX(sbex.sbex_oid)
    FROM ft_cfg_sbex sbex, ft_cfg_sbdf sbdf
    WHERE sbex.sbdf_oid = sbdf.sbdf_oid
    AND sbdf.subscription_nme = 'EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB'
);

COMMIT;