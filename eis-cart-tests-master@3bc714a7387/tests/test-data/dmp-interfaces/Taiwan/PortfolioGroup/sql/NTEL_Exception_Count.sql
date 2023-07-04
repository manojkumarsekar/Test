SELECT Count(DISTINCT(CHAR_VAL_TXT)) AS NTEL_EXCEPTION_COUNT
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
                                                  AND job_input_txt LIKE '%${INPUT_FILENAME}'
                                                  AND task_cmpltd_cnt > 0)
                           AND ntel.notfcn_stat_typ = 'OPEN'
                           AND ntel.msg_typ = 'EIS_MT_BRS_PORTFOLIO_GROUP'
                           AND (char_val_txt like('%Cannot process file as required fields PORTFOLIO_GROUP_NAME, FUND is not present in the input record%')
                            or char_val_txt like ('%received from BRS  could not be retrieved from the AccountAlternateIdentifier%'))