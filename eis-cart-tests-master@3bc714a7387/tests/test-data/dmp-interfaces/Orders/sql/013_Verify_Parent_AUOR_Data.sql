SELECT
    COUNT(*) AS RECORD_COUNT
FROM
    ft_t_auor
WHERE
    pref_order_id = 'TST1725736'
    AND   acct_id IS NULL
    AND   instr_id IN (
        SELECT
            instr_id
        FROM
            ft_t_isid
        WHERE
            iss_id = 'SB037HF18'
            AND   id_ctxt_typ = 'BCUSIP'
    )
    AND   athd_order_typ = 'MARKET'
    AND   buy_sell_typ = 'B'
    AND   curr_cde = 'INR'
    AND   order_cqty = '22618'
    AND   exec_cqty = '22618'
    AND   exec_cprc = '142.1138'
    AND   order_as_of_tms = TO_DATE('03-DEC-2018 05:27:06','DD-MON-YYYY HH24:MI:SS')
    AND   order_proc_tms = TO_DATE('03-DEC-2018 05:27:06','DD-MON-YYYY HH24:MI:SS')
    AND   trn_cde = 'BUY'
    AND   cmnt_txt = 'ESI.ID 26'
    AND   earliest_exec_tms = TO_DATE('03-DEC-2018 00:00:00','DD-MON-YYYY HH24:MI:SS')
    AND   mkt_prc_cprc = '140.3'
    AND   order_limit_camt = '10'
    AND   order_limit_typ = 'P'
    AND   order_originator_typ = 'T'