    SELECT Count(DISTINCT(CHAR_VAL_TXT)) AS EXCEPTION_ROW_COUNT
                    FROM   ft_t_ntel ntel
                           join ft_t_trid trid
                             ON ntel.last_chg_trn_id = trid.trn_id
                    WHERE  trid.job_id IN (SELECT job_id
                                           FROM   ft_t_jblg
                                           WHERE  To_timestamp(To_char(job_start_tms,
                                                               'DD-MON-YYYYHH24:MI:SS'),
                                                          'DD-MON-YYYYHH24:MI:SS') >=
                                                  To_timestamp(To_char((SELECT
                                                               workflow_start_tms
                                                                        FROM
                                                               ft_wf_wfri
                                                                        WHERE
                                                               instance_id =
                                                               '${flowResultId}'
                                                                       ),
                                                               'DD-MON-YYYYHH24:MI:SS'
                                                               ),
                                                                      'DD-MON-YYYYHH24:MI:SS')
                                                  AND job_input_txt LIKE '%${INPUT_FILENAME1}'
                                                  AND task_cmpltd_cnt > 0)
                           AND ntel.notfcn_stat_typ = 'OPEN'
                           AND ntel.notfcn_id = '60001'
                           AND ntel.msg_typ = 'ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION'
                           AND ntel.parm_val_txt LIKE '%Cannot process the record%'