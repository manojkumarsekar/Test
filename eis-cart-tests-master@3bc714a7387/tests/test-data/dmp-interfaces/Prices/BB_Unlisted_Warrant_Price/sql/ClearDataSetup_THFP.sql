DELETE FROM gs_gc.ft_t_ispc
WHERE  last_chg_tms > Trunc(to_date ('${PRC_TMS}','YYYYMMDD'))
       AND instr_id IN (SELECT instr_id
                        FROM   gs_gc.ft_t_isid
                        WHERE  iss_id  ='BES2XRRY6'
                               AND id_ctxt_typ = 'BCUSIP'
                               AND end_tms IS NULL);


INSERT INTO ft_t_isgp
(SELECT (SELECT iss_grp_oid
         FROM   ft_t_isgr
         WHERE  iss_grp_id = 'UNLWARSOI'
                AND end_tms IS NULL),
        to_date ('${PRC_TMS}','YYYYMMDD'),
        NULL,
        instr_id,
        to_date ('${PRC_TMS}','YYYYMMDD'),
        'EIS:CSTM',
        'MEMBER',
        NULL,
        NULL,
        NULL,
        NULL,
        'ACTIVE',
        'Unlisted Warrant Pricing',
        NULL,
        NULL,
        NULL,
        NULL,
        new_oid,
        NULL
 FROM   ft_t_isid
 WHERE  id_ctxt_typ = 'BCUSIP'
        AND iss_id IN ( 'BES2XRRY6')
        AND end_tms IS NULL);

update ft_t_riss set instr_id = (select instr_id from ft_t_isid where iss_id = 'TH1027010012' and end_tms is null) where RLD_ISS_FEAT_ID in(
select RLD_ISS_FEAT_ID from ft_t_ridf where instr_id in (select instr_id FROM   ft_t_isid
 WHERE  id_ctxt_typ = 'BCUSIP'
        AND iss_id IN ( 'BES2XRRY6')
        AND end_tms IS NULL));


delete ft_t_ispc where prc_typ = 'DERIVE' AND prc_srce_typ = 'ESTHF' AND prc_valid_typ = 'VALID' AND prcng_meth_typ = 'ESITHP' AND Trunc(prc_tms) = Trunc(to_date ('${PRC_TMS}','YYYYMMDD'))
and instr_id in (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH1027010012');

UPDATE ft_t_ispc
SET    unit_cprc = 23.57, prc_tms = to_date ('${PRC_TMS}','YYYYMMDD'),
       last_chg_usr_id = 'THAIAUTOMATION'
WHERE  iss_prc_id IN(SELECT iss_prc_id
                     FROM   (SELECT iss_prc_id,
                                    instr_id,
                                    Row_number()
                                      OVER (
                                        partition BY instr_id
                                        ORDER BY prc_tms DESC, last_chg_tms DESC
                                      ) AS
                                    RECORD_ORDER
                             FROM   ft_t_ispc
                             WHERE  prc_typ = 'DERIVE'
                                    AND prc_srce_typ = 'ESTHF'
                                    AND prc_valid_typ = 'VALID'
                                    AND prcng_meth_typ = 'ESITHP'
                                    AND Trunc(prc_tms) != Trunc(to_date ('${PRC_TMS}','YYYYMMDD')))
                     WHERE  record_order = 1)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH1027010012');

Insert into FT_T_ISPC (ISS_PRC_ID,INSTR_ID,PRC_TMS,PRC_SRCE_TYP,PRC_CURR_CDE,PRC_QT_METH_TYP,PRC_TYP,PRCNG_METH_TYP,PRC_VALID_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,
DATA_SRC_ID,UNIT_CPRC,ADJST_TMS,PPED_OID) values (new_oid,(SELECT instr_id FROM ft_t_isid WHERE  end_tms IS NULL AND id_ctxt_typ = 'ISIN' AND iss_id = 'TH1027010012'),to_date ('${PRC_TMS}','YYYYMMDD'),'ESALL','THB','PRCQUOTE','CL1D    ','ESIPX   ','UNVERIFD',to_date ('${PRC_TMS}','YYYYMMDD'),'UWAUTOMATION','BB',47.75,to_date ('${PRC_TMS}','YYYYMMDD'),'ESIPRPTEOD');

COMMIT;