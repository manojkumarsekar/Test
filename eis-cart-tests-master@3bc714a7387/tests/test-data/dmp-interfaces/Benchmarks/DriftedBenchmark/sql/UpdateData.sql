UPDATE ft_t_bnvl
SET bnchmrk_val_tms = trunc(sysdate) - 1,
    open_wgt_bmrk_crte = close_wgt_bmrk_crte,
    open_cprc = close_cprc,
    last_chg_tms = sysdate,
    last_chg_usr_id = 'TOM-3255 Automation'
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

COMMIT;