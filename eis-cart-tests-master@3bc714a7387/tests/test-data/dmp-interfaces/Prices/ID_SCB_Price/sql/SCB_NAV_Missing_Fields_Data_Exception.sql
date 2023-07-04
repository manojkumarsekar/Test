SELECT Count(DISTINCT(CHAR_VAL_TXT)) AS EXCEPTION_ROW_COUNT
                    FROM   ft_t_ntel ntel
                           join ft_t_trid trid
                             ON ntel.last_chg_trn_id = trid.trn_id
                    WHERE  trid.job_id = '${JOB_ID}'
                           AND ntel.notfcn_stat_typ = 'OPEN'
                           AND ntel.notfcn_id = '153'
                           AND ntel.msg_typ = 'ESII_MT_SCB_DMP_NAV'
                           AND ntel.main_entity_id ='EII01DFCNADDMF00'
                           AND ntel.parm_val_txt LIKE '%Table Initial Occurence: 4 No lookup indentifier available%'