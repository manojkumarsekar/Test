DELETE FROM ft_t_isgp
WHERE  prnt_iss_grp_oid = (SELECT iss_grp_oid
                               FROM   ft_t_isgr
                               WHERE  iss_grp_id = 'STLPRCSOI');

INSERT INTO ft_t_isgp
            (prnt_iss_grp_oid,
             start_tms,
             instr_id,
             last_chg_tms,
             last_chg_usr_id,
             prt_purp_typ,
             isgp_oid)
SELECT (SELECT iss_grp_oid
        FROM   ft_t_isgr
        WHERE  iss_grp_id = 'STLPRCSOI') PRNT_ISS_GRP_OID,
       sysdate                           START_TMS,
       instr_id,
       sysdate                           LAST_CHG_TMS,
       'EIS:CSTM'                        LAST_CHG_USR_ID,
       'MEMBER'                          PRT_PURP_TYP,
       new_oid                           ISGP_OID
FROM   ft_t_isid isid
WHERE  iss_id IN ( 'ESL7706444', 'ESL8950744', 'ESL6497473', 'ESL3721369',
                   'ESL9609262'
                        )
       AND end_tms IS NULL
       AND id_ctxt_typ = 'EISLSTID'
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_isgp
                       WHERE  instr_id = isid.instr_id
                              AND ft_t_isgp.prnt_iss_grp_oid = (SELECT
                                  iss_grp_oid
                                                                FROM   ft_t_isgr
                                                                WHERE
                                  iss_grp_id = 'STLPRCSOI'
                                                               ));

DELETE FROM ft_t_ispc
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id IN ( 'ESL7706444', 'ESL8950744', 'ESL6497473',
                                       'ESL3721369',
                                       'ESL9609262'
                                             )
                           AND id_ctxt_typ = 'EISLSTID')
       AND prc_tms >= To_date('31-MAR-20 00:00:00', 'DD-MON-RR HH24:MI:SS');

DELETE FROM ft_t_ispc
WHERE  prc_tms = '31-MAR-2020'
       AND last_chg_usr_id = 'BATCHJOBESISTALE'
       AND Trunc(last_chg_tms) = Trunc(sysdate);

DELETE FROM ft_t_ispc
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id IN ( 'ESL7706444', 'ESL8950744', 'ESL6497473',
                                       'ESL3721369',
                                       'ESL9609262'
                                             )
                           AND id_ctxt_typ = 'EISLSTID')
       AND prc_tms IN ( To_date('28-FEB-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
                        To_date(
                                       '16-MAR-20 00:00:00',
                        'DD-MON-RR HH24:MI:SS') );

INSERT INTO ft_t_ispc
            (iss_prc_id,
             instr_id,
             prc_tms,
             prc_srce_typ,
             prc_curr_cde,
             prc_qt_meth_typ,
             prc_typ,
             prcng_meth_typ,
             prc_valid_typ,
             last_chg_tms,
             last_chg_usr_id,
             data_src_id,
             unit_cprc,
             orig_data_prov_id,
             job_id,
             trn_id,
             adjst_tms)
VALUES      (New_oid(),
             (SELECT instr_id
              FROM   ft_t_isid
              WHERE  iss_id = 'ESL7706444'
                     AND id_ctxt_typ = 'EISLSTID'),
             To_date('28-FEB-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
             'ESM',
             'USD',
             'PRCQUOTE',
             'SODEIS  ',
             'ESIPX   ',
             'CHECKED',
             To_date('02-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'),
             'EIS_EDM_DMP_PRICE',
             'EIS',
             100,
             'ESI',
             '++7cJfhGh4eWq2gY',
             '007cZEe0h4eWq1bG',
             To_date('02-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'));

INSERT INTO ft_t_ispc
            (iss_prc_id,
             instr_id,
             prc_tms,
             prc_srce_typ,
             prc_curr_cde,
             prc_qt_meth_typ,
             prc_typ,
             prcng_meth_typ,
             prc_valid_typ,
             last_chg_tms,
             last_chg_usr_id,
             data_src_id,
             unit_cprc,
             orig_data_prov_id,
             job_id,
             trn_id,
             adjst_tms)
VALUES      (New_oid(),
             (SELECT instr_id
              FROM   ft_t_isid
              WHERE  iss_id = 'ESL8950744'
                     AND id_ctxt_typ = 'EISLSTID'),
             To_date('16-MAR-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
             'ESM',
             'VND',
             'PRCQUOTE',
             'SODEIS  ',
             'ESIPX   ',
             'CHECKED',
             To_date('18-MAR-20 11:00:32', 'DD-MON-RR HH24:MI:SS'),
             'EIS_EDM_DMP_PRICE',
             'EIS',
             8.5618,
             'ESI',
             '++7dttemh6eWi011',
             '++7dttemh6eWi015',
             To_date('18-MAR-20 11:00:32', 'DD-MON-RR HH24:MI:SS'));

INSERT INTO ft_t_ispc
            (iss_prc_id,
             instr_id,
             prc_tms,
             prc_srce_typ,
             prc_curr_cde,
             prc_qt_meth_typ,
             prc_typ,
             prcng_meth_typ,
             prc_valid_typ,
             last_chg_tms,
             last_chg_usr_id,
             data_src_id,
             unit_cprc,
             orig_data_prov_id,
             job_id,
             trn_id,
             adjst_tms)
VALUES      (New_oid(),
             (SELECT instr_id
              FROM   ft_t_isid
              WHERE  iss_id = 'ESL6497473'
                     AND id_ctxt_typ = 'EISLSTID'),
             To_date('16-MAR-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
             'ESM',
             'TWD',
             'PRCQUOTE',
             'SODEIS  ',
             'ESIPX   ',
             'CHECKED',
             To_date('18-MAR-20 11:00:32', 'DD-MON-RR HH24:MI:SS'),
             'EIS_EDM_DMP_PRICE',
             'EIS',
             10.5919,
             'ESI',
             '++7dttemh6eWi011',
             '++7dttemh6eWi016',
             To_date('18-MAR-20 11:00:32', 'DD-MON-RR HH24:MI:SS'));

INSERT INTO ft_t_ispc
            (iss_prc_id,
             instr_id,
             prc_tms,
             prc_srce_typ,
             prc_curr_cde,
             prc_qt_meth_typ,
             prc_typ,
             prcng_meth_typ,
             prc_valid_typ,
             last_chg_tms,
             last_chg_usr_id,
             data_src_id,
             unit_cprc,
             orig_data_prov_id,
             job_id,
             trn_id,
             adjst_tms)
VALUES      (New_oid(),
             (SELECT instr_id
              FROM   ft_t_isid
              WHERE  iss_id = 'ESL3721369'
                     AND id_ctxt_typ = 'EISLSTID'),
             To_date('28-FEB-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
             'ESM',
             'THB',
             'PRCQUOTE',
             'SODEIS  ',
             'ESIPX   ',
             'CHECKED',
             To_date('02-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'),
             'EIS_EDM_DMP_PRICE',
             'EIS',
             101.69,
             'ESI',
             '++7cJfhGh4eWq2gY',
             '007cZEe0h4eWq1cI',
             To_date('02-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'));

INSERT INTO ft_t_ispc
            (iss_prc_id,
             instr_id,
             prc_tms,
             prc_srce_typ,
             prc_curr_cde,
             prc_qt_meth_typ,
             prc_typ,
             prcng_meth_typ,
             prc_valid_typ,
             last_chg_tms,
             last_chg_usr_id,
             data_src_id,
             unit_cprc,
             orig_data_prov_id,
             job_id,
             trn_id,
             adjst_tms)
VALUES      (New_oid(),
             (SELECT instr_id
              FROM   ft_t_isid
              WHERE  iss_id = 'ESL9609262'
                     AND id_ctxt_typ = 'EISLSTID'),
             To_date('28-FEB-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
             'ESM',
             'THB',
             'PRCQUOTE',
             'SODEIS  ',
             'ESIPX   ',
             'CHECKED',
             To_date('02-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'),
             'EIS_EDM_DMP_PRICE',
             'EIS',
             100.87,
             'ESI',
             '++7cJfhGh4eWq2gY',
             '007cZEe0h4eWq1cH',
             To_date('02-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'));

INSERT INTO ft_t_ispc
            (iss_prc_id,
             instr_id,
             prc_tms,
             prc_srce_typ,
             prc_curr_cde,
             prc_qt_meth_typ,
             prc_typ,
             prcng_meth_typ,
             prc_valid_typ,
             last_chg_tms,
             last_chg_usr_id,
             data_src_id,
             unit_cprc,
             orig_data_prov_id,
             job_id,
             trn_id,
             adjst_tms)
VALUES      (New_oid(),
             (SELECT instr_id
              FROM   ft_t_isid
              WHERE  iss_id = 'ESL9609262'
                     AND id_ctxt_typ = 'EISLSTID'),
             To_date('28-FEB-20 00:00:00', 'DD-MON-RR HH24:MI:SS'),
             'ESM',
             'THB',
             'PRCQUOTE',
             'SODEIS  ',
             'ESIPX   ',
             'CHECKED',
             To_date('03-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'),
             'EIS_EDM_DMP_PRICE',
             'EIS',
             101.87,
             'ESI',
             '++7cJfhGh4eWq2gY',
             '007cZEe0h4eWq1cH',
             To_date('03-MAR-20 19:30:33', 'DD-MON-RR HH24:MI:SS'));