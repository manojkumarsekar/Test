DELETE ft_t_accr
WHERE
    rep_acct_id IN (
        SELECT
            acct_id
        FROM
            ft_t_acid
        WHERE
            acct_alt_id = 'U_TT4422'
            AND   acct_id_ctxt_typ = 'CRTSID'
            AND   end_tms IS NULL
    )
    AND   rl_typ = 'BRSSPLIT'
    AND   end_tms IS NULL;

DELETE ft_cfg_sbex
WHERE
    sbdf_oid IN (
        SELECT
            sbdf_oid
        FROM
            ft_cfg_sbdf
        WHERE
            subscription_nme = 'EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM'
    );

COMMIT;