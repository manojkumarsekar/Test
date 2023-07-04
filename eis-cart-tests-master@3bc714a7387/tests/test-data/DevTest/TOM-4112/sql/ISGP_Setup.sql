INSERT INTO ft_t_isgp
            (prnt_iss_grp_oid,
             start_tms,
             instr_id,
             last_chg_tms,
             last_chg_usr_id,
             prt_purp_typ,
             isgp_oid,
             data_stat_typ)
SELECT (SELECT iss_grp_oid
        FROM   ft_t_isgr
        WHERE  iss_grp_id = 'BBPRICEGRP'
               AND end_tms IS NULL) PRNT_ISS_GRP_OID,
       sysdate                      START_TMS,
       instr_id,
       sysdate                      LAST_CHG_TMS,
       'EIS:CSTM'                   LAST_CHG_USR_ID,
       'MEMBER'                     PRT_PURP_TYP,
       new_oid                      ISGP_OID,
       'ACTIVE'                     DATA_STAT_TYP
FROM   ft_t_isid isid
WHERE  iss_id IN ( 'LU0440258258', 'GB0030932452', 'GB00F75H9F84',
                   'IE00B19Z9505' )
       AND end_tms IS NULL
       AND id_ctxt_typ = 'ISIN'
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_isgp
                       WHERE  instr_id = isid.instr_id
                              AND end_tms IS NULL
                              AND ft_t_isgp.prnt_iss_grp_oid = (SELECT
                                  iss_grp_oid
                                                                FROM   ft_t_isgr
                                                                WHERE
                                  iss_grp_id = 'BBPRICEGRP'
                                  AND end_tms IS NULL));