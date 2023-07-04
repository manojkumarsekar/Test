SELECT
    COUNT(*) AS ACID_SITCAFNDID_ROW_COUNT
FROM
    ft_t_acid
WHERE
    acct_id IN (
        SELECT
            acct_id
        FROM
            ft_t_acct
        WHERE
            acct_nme IN (
                'TST-TRD2-RDM',
                'TST-TRD3-RDM',
                'TST-TRD1-RDM',
                'TST-TRD2',
                'TST-TRD1',
                'TST-TRD3'
            )
    )
    AND   trunc(last_chg_tms) = trunc(SYSDATE)
    AND   acct_id_ctxt_typ in ('SITCAFNDID', 'SCSITCAFNDID')
    AND   data_src_id = 'EIS'
    AND   last_chg_usr_id = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND   end_tms IS NULL