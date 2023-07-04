SELECT
    COUNT(1) AS EXTR_NEW_CASH_COUNT
FROM
    ft_t_extr extr
    INNER JOIN ft_t_etmg etmg ON extr.exec_trd_id = etmg.exec_trd_id
    INNER JOIN ft_t_etid etid ON extr.exec_trd_id = etid.exec_trd_id
    INNER JOIN ft_t_acid acid ON extr.acct_id = acid.acct_id
                                 AND acid.acct_id_ctxt_typ = 'SCUNIBUSNUM'
WHERE
    trn_cde = 'TWFASCASHTXN'
    AND   (
        (
            trunc(extr.last_chg_tms) = trunc(SYSDATE)
            AND   extr.trd_id = 'TEST_20180521_0000060'
            AND   acid.acct_alt_id = 'TST-TRD1-SH-CLUBN'
            AND   net_settle_camt = '10900000'
            AND   extr.settle_curr_cde = 'TWD'
            AND   exec_trn_cl_typ = 'C'
            AND   settle_dte = TO_DATE('21/05/2018','DD/MM/YYYY')
            AND   trd_dte = TO_DATE('21/05/2018','DD/MM/YYYY')
        )
        OR    (
            trunc(extr.last_chg_tms) = trunc(SYSDATE)
            AND   extr.trd_id = 'TEST_20180521_0000061'
            AND   acid.acct_alt_id = 'TST-TRD2-SH-CLUBN'
            AND   net_settle_camt = '10100000'
            AND   extr.settle_curr_cde = 'USD'
            AND   exec_trn_cl_typ = 'D'
            AND   settle_dte = TO_DATE('21/05/2018','DD/MM/YYYY')
            AND   trd_dte = TO_DATE('21/05/2018','DD/MM/YYYY')
        )
        OR    (
            trunc(extr.last_chg_tms) = trunc(SYSDATE)
            AND   extr.trd_id = 'TEST_20180521_0000062'
            AND   acid.acct_alt_id = 'TST-TRD3-SH-CLUBN'
            AND   net_settle_camt = '10100000'
            AND   extr.settle_curr_cde = 'USD'
            AND   exec_trn_cl_typ = 'D'
            AND   settle_dte = TO_DATE('21/05/2018','DD/MM/YYYY')
            AND   trd_dte = TO_DATE('21/05/2018','DD/MM/YYYY')
        )
    )