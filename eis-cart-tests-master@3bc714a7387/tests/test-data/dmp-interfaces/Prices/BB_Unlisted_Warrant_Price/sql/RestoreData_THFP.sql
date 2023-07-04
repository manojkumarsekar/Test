DELETE FROM gs_gc.ft_t_ispc
WHERE  last_chg_tms > Trunc(to_date ('${PRC_TMS}','YYYYMMDD'))
       AND instr_id IN (SELECT instr_id
                        FROM   gs_gc.ft_t_isid
                        WHERE  iss_id  ='BES2XRRY6'
                               AND id_ctxt_typ = 'BCUSIP'
                               AND end_tms IS NULL);


DELETE from ft_t_isgp WHERE prnt_ISS_GRP_OID IN (SELECT ISS_GRP_OID from fT_T_isgr where iss_grp_id  = 'UNLWARSOI' AND end_tms is null)
AND instr_id IN (SELECT instr_id FROM ft_t_isid  WHERE id_ctxt_typ = 'BCUSIP'  AND iss_id = 'BES2XRRY6' AND end_tms IS NULL);

update ft_t_riss set instr_id = (select instr_id from ft_t_isid where iss_id = 'TH6141010004' and id_ctxt_typ = 'ISIN' and end_tms is null) where RLD_ISS_FEAT_ID in(
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

delete from ft_t_ispc where last_chg_usr_id = 'UWAUTOMATION';

commit;