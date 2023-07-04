CREATE TABLE ft_t_inlm_bkp AS SELECT * FROM ft_t_inlm where instr_id in (select instr_id from ft_t_isid where iss_Id in
            ('TH5097010000','TH0637010Y00','TH8319010Z06','TH3871010Z01','TH0264A10Z04','TH0375010Z06',
                         'TH0999010Z03','TH0450010Y08','TH9597010007','TH0465010005','TH0015010000','TH1027010004','TH0689010Z00'));

DELETE ft_t_inlm where instr_id in (select instr_id from ft_t_isid where iss_Id in
            ('TH5097010000','TH0637010Y00','TH8319010Z06','TH3871010Z01','TH0264A10Z04','TH0375010Z06',
            'TH0999010Z03','TH0450010Y08','TH9597010007','TH0465010005','TH0015010000','TH1027010004','TH0689010Z00'));


Insert into FT_T_INLM (INLM_OID,INSTR_ID,LIMIT_TYP,START_TMS,LIMIT_CAMT,LAST_CHG_TMS,LAST_CHG_USR_ID,DATA_SRC_ID) 
select new_oid,
isid.instr_id,
'FIICPCT',
sysdate,
11.7718,
sysdate,
'THAIAUTOMATION',
'BB'
FROM   ft_t_isid isid
WHERE  iss_id IN ('TH0637010Y00','TH8319010Z06','TH3871010Z01')
       AND id_ctxt_typ = 'ISIN'
       AND end_tms IS NULL
       AND NOT EXISTS (SELECT 1
                       FROM   FT_T_INLM
                       WHERE  LIMIT_TYP = 'FIICPCT'
                              AND end_tms IS NULL
                              and trunc(LAST_CHG_TMS) = trunc(sysdate)
                              AND instr_id = isid.instr_id);

Insert into FT_T_INLM (INLM_OID,INSTR_ID,LIMIT_TYP,START_TMS,LIMIT_CAMT,LAST_CHG_TMS,LAST_CHG_USR_ID,DATA_SRC_ID)
select new_oid,
isid.instr_id,
'FIICPCT',
sysdate,
0,
sysdate,
'THAIAUTOMATION',
'BB'
FROM   ft_t_isid isid
WHERE  iss_id IN ('TH0450010Y08','TH9597010007','TH0465010005','TH0015010000','TH1027010004','TH0689010Z00')
       AND id_ctxt_typ = 'ISIN'
       AND end_tms IS NULL
       AND NOT EXISTS (SELECT 1
                       FROM   FT_T_INLM
                       WHERE  LIMIT_TYP = 'FIICPCT'
                              AND end_tms IS NULL
                              and trunc(LAST_CHG_TMS) = trunc(sysdate)
                              AND instr_id = isid.instr_id);


commit;