  SELECT Count(DISTINCT(CHAR_VAL_TXT)) AS EXCEPTION_ROW_COUNT
                    FROM   ft_t_ntel ntel
                           join ft_t_trid trid
                             ON ntel.last_chg_trn_id = trid.trn_id
                    WHERE  trid.job_id = '${JOB_ID}'
                           AND ntel.notfcn_stat_typ = 'OPEN'
                           AND ntel.notfcn_id = '60001'
                           AND ntel.msg_typ = 'EIS_MT_MNG_DMP_SECURITY'
                           AND ntel.parm_val_txt LIKE '%User defined Error%'