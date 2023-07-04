DELETE FROM ft_t_ispc
WHERE  Trim(prcng_meth_typ) = 'ESIPX'
       AND prc_qt_meth_typ = 'PRCQUOTE'
       AND prc_srce_typ = 'ESM'
       AND Trunc(prc_tms) in (to_date('22-MAY-2019', 'DD-MON-YYYY'),to_date('25-MAY-2019', 'DD-MON-YYYY'),to_date('10-MAY-2019', 'DD-MON-YYYY'))
       AND prc_typ = 'SODEIS  '
       AND prc_valid_typ = 'CHECKED'
       AND Trunc(adjst_tms) = Trunc(sysdate)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  iss_id IN ( 'HK0274',
                                           'HK0273',
                                           'HK0460' )
                               AND id_ctxt_typ = 'BROKERFUNDCD'
                               AND end_tms IS NULL);

INSERT INTO ft_t_isid
            (isid_oid,
             instr_id,
             id_ctxt_typ,
             iss_id,
             start_tms,
             last_chg_tms,
             last_chg_usr_id,
             mkt_oid,
             data_stat_typ,
             data_src_id,
             global_uniq_ind)
SELECT New_oid(),
       instr_id,
       'BROKERFUNDCD',
       'HK0274',
       sysdate,
       sysdate,
       last_chg_usr_id,
       mkt_oid,
       data_stat_typ,
       data_src_id,
       global_uniq_ind
FROM   ft_t_isid
WHERE  iss_id IN ( 'ESL3409588' )
       AND id_ctxt_typ = 'EISLSTID'
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_isid
                       WHERE  id_ctxt_typ = 'BROKERFUNDCD'
                              AND iss_id = 'HK0274');

INSERT INTO ft_t_isid
            (isid_oid,
             instr_id,
             id_ctxt_typ,
             iss_id,
             start_tms,
             last_chg_tms,
             last_chg_usr_id,
             mkt_oid,
             data_stat_typ,
             data_src_id,
             global_uniq_ind)
SELECT New_oid(),
       instr_id,
       'BROKERFUNDCD',
       'HK0273',
       sysdate,
       sysdate,
       last_chg_usr_id,
       mkt_oid,
       data_stat_typ,
       data_src_id,
       global_uniq_ind
FROM   ft_t_isid
WHERE  iss_id IN ( 'ESL7931475' )
       AND id_ctxt_typ = 'EISLSTID'
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_isid
                       WHERE  id_ctxt_typ = 'BROKERFUNDCD'
                              AND iss_id = 'HK0273');

INSERT INTO ft_t_isid
            (isid_oid,
             instr_id,
             id_ctxt_typ,
             iss_id,
             start_tms,
             last_chg_tms,
             last_chg_usr_id,
             mkt_oid,
             data_stat_typ,
             data_src_id,
             global_uniq_ind)
SELECT New_oid(),
       instr_id,
       'BROKERFUNDCD',
       'HK0460',
       sysdate,
       sysdate,
       last_chg_usr_id,
       mkt_oid,
       data_stat_typ,
       data_src_id,
       global_uniq_ind
FROM   ft_t_isid
WHERE  iss_id IN ( 'ESL5707198' )
       AND id_ctxt_typ = 'EISLSTID'
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_isid
                       WHERE  id_ctxt_typ = 'BROKERFUNDCD'
                              AND iss_id = 'HK0460');