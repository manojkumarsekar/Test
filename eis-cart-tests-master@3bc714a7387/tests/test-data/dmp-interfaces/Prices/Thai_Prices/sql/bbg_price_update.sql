update ft_t_ispc set prc_valid_typ = 'IGNORE',LAST_CHG_USR_ID = 'THAIAUTOMATION' where prc_typ = '003' AND prc_valid_typ = 'UNVERIFD'
and data_src_id = 'BB' and instr_id in (select instr_id from ft_t_isid where iss_id in ('TH3871010Z01','TH0999010Z03','TH0015010000','TH0689010Z00') and end_tms is null);

update ft_t_ispc set prc_valid_typ = 'IGNORE',LAST_CHG_USR_ID = 'THAIAUTOMATION' WHERE  prc_typ = 'DERIVE' AND prc_srce_typ = 'ESTHF' AND prc_valid_typ = 'VALID'
AND prcng_meth_typ = 'ESITHP' and instr_id in (select instr_id from ft_t_isid where iss_id = 'TH0689010Z18' and end_tms is null);


UPDATE ft_t_ispc
SET    unit_cprc = 26.8,
       last_chg_usr_id = 'THAIAUTOMATION' ,
       prc_tms = trunc(sysdate-1)
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
                                    AND Trunc(prc_tms) != Trunc(sysdate+1))
                     WHERE  record_order = 1)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH9597010015');


UPDATE ft_t_ispc
SET    unit_cprc = 26.8,
       last_chg_usr_id = 'THAIAUTOMATION' ,
       prc_tms = trunc(sysdate)
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
                                    AND Trunc(prc_tms) != Trunc(sysdate+1))
                     WHERE  record_order = 2)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH9597010015');

UPDATE ft_t_ispc
SET    unit_cprc = 215,
       last_chg_usr_id = 'THAIAUTOMATION' ,
       prc_tms = trunc(sysdate)
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
                                    AND Trunc(prc_tms) != Trunc(sysdate+1))
                     WHERE  record_order = 1)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH0465010013');

UPDATE ft_t_ispc
SET    unit_cprc = 215.1,
       last_chg_usr_id = 'THAIAUTOMATION' ,
       prc_tms = trunc(sysdate-1)
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
                                    AND Trunc(prc_tms) != Trunc(sysdate+1))
                     WHERE  record_order = 2)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH0465010013');

UPDATE ft_t_ispc
SET    unit_cprc = 90.75,
       last_chg_usr_id = 'THAIAUTOMATION' ,
       prc_tms = trunc(sysdate-1)
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
                                    AND Trunc(prc_tms) != Trunc(sysdate+1))
                     WHERE  record_order = 1)
       AND instr_id IN (SELECT instr_id
                        FROM   ft_t_isid
                        WHERE  end_tms IS NULL
                               AND id_ctxt_typ = 'ISIN'
                               AND iss_id = 'TH0015010018');