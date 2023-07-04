SELECT count(*) AS NON_BLANK_EOD_WEIGHT_COUNT FROM ft_t_bnch bnch
    INNER JOIN ft_t_bnpt bnpt
        ON bnpt.prnt_bnch_oid = bnch.bnch_oid
            AND bnch.end_tms IS NULL
            AND bnpt.end_tms IS NULL
    INNER JOIN ft_t_bnvl bnvl
        ON bnvl.bnpt_oid = bnpt.bnpt_oid
    INNER JOIN ft_t_bnid bnid
        ON bnid.bnch_oid = bnch.bnch_oid
            AND bnid.end_tms IS NULL
            AND bnid.bnchmrk_id_ctxt_typ = 'BRSBNCHID'
            AND substr(bnid.bnchmrk_id, 0, 3) = 'GMP'
    INNER JOIN ft_t_isid isid
        ON bnpt.instr_id = isid.instr_id
            AND isid.end_tms IS NULL
            AND isid.id_ctxt_typ = 'BCUSIP'
WHERE trunc(bnvl.bnchmrk_val_tms) =
(
    SELECT trunc(max(bnvl.bnchmrk_val_tms))
    FROM ft_t_bnch bnch
        INNER JOIN ft_t_bnpt bnpt
            ON bnpt.prnt_bnch_oid = bnch.bnch_oid
                AND bnch.end_tms IS NULL
                AND bnpt.end_tms IS NULL
        INNER JOIN ft_t_bnvl bnvl
            ON bnvl.bnpt_oid = bnpt.bnpt_oid
        INNER JOIN ft_t_bnid bnid
            ON bnid.bnch_oid = bnch.bnch_oid
                AND bnid.end_tms IS NULL
                AND bnid.bnchmrk_id_ctxt_typ = 'BRSBNCHID'
                AND substr(bnid.bnchmrk_id, 0, 3) = 'GMP'
                AND bnid.bnchmrk_id IN ('GMP_ABTSLF', 'GMP_AHOBI6', 'GMP_AHOBIN', 'GMP_AHOBLF', 'GMP_AHOHKD', 'GMP_AHOPGH')
)
AND bnvl.close_wgt_bmrk_crte IS NOT NULL