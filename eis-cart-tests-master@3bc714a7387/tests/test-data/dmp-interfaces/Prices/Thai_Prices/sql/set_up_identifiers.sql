UPDATE ft_t_isid isid
SET    end_tms = NULL, 
       last_chg_usr_id = 'THAIAUTOMATION'
WHERE  isid_oid IN(SELECT isid_oid 
                   FROM   (SELECT iss_id, 
                                  isid_oid, 
                                  Row_number() 
                                    OVER ( 
                                      partition BY iss_id 
                                      ORDER BY end_tms DESC) AS RECORD_ORDER 
                           FROM   ft_t_isid 
                           WHERE  id_ctxt_typ = 'ISIN' 
                                  AND end_tms IS NOT NULL) 
                   WHERE  record_order = 1) 
       AND iss_id in ( 'TH5097010018','TH0637010Y18','TH8319010Z14','TH3871010Z19','TH0264A10Z12',
                        'TH0375010Z14','TH0999010Z11','TH0450010Y16','TH9597010015','TH0465010013',
                        'TH0015010018','TH1027010012','TH0689010Z18','TH5097010000','TH0637010Y00',
                        'TH8319010Z06','TH3871010Z01','TH0264A10Z04','TH0375010Z06','TH0999010Z03',
                        'TH0450010Y08','TH9597010007','TH0465010005','TH0015010000','TH1027010004','TH0689010Z00' )
       AND NOT EXISTS(SELECT iss_id 
                      FROM   ft_t_isid 
                      WHERE  iss_id = isid.iss_id 
                             AND end_tms IS NULL) ;
                             
commit;