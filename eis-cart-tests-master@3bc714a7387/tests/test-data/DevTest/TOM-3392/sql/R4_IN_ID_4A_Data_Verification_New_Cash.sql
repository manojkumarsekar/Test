 SELECT Count(1) AS EXTR_NEW_CASH_COUNT
               FROM   ft_t_extr extr
                      inner join ft_t_exst exst
                              ON extr.exec_trd_id = exst.exec_trd_id
                      inner join ft_t_etmg etmg
                              ON extr.exec_trd_id = etmg.exec_trd_id
                      inner join ft_t_etid etid
                              ON extr.exec_trd_id = etid.exec_trd_id
                      inner join ft_t_acid acid
                              ON extr.acct_id = acid.acct_id
                                 AND acid.acct_id_ctxt_typ = 'CRTSID'
               WHERE  trn_cde = 'ESIICASHTXN'
                      AND exec_trn_cat_typ = 'NEW CASH'
                      AND trd_cqty = '0'
                      AND ( ( Trunc(extr.last_chg_tms) = Trunc(SYSDATE)
                              AND extr.trd_id = '123'
                              AND acid.acct_alt_id = 'NDSICF'
                              AND net_settle_camt = '2300000'
                              AND extr.settle_curr_cde = 'IDR'
                              AND exec_trn_cl_typ = 'C'
                              AND settle_dte = To_date('28/06/2018', 'DD/MM/YYYY')
                              AND trd_dte = To_date('25/06/2018', 'DD/MM/YYYY')
                              AND trd_legend_txt = 'NewCash for NDSICF'
                              AND exec_trd_stat_typ = 'NEWM'
                             )
                             OR ( Trunc(extr.last_chg_tms) = Trunc(SYSDATE)
                                  AND extr.trd_id = '456'
                                  AND acid.acct_alt_id = 'ADPSEF'
                                  AND net_settle_camt = '456789.67'
                                  AND extr.settle_curr_cde = 'IDR'
                                  AND exec_trn_cl_typ = 'D'
                                  AND settle_dte = To_date('28/06/2018', 'DD/MM/YYYY')
                                  AND trd_dte = To_date('22/06/2018', 'DD/MM/YYYY')
                                  AND trd_legend_txt IS NULL
                                  AND exec_trd_stat_typ = 'NEWM'
                                 ) )