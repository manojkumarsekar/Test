INSERT INTO ft_t_balh 
            (balh_oid, 
             org_id, 
             bk_id, 
             acct_id, 
             ldgr_id, 
             prin_inc_ind, 
             instr_id, 
             hst_reas_typ, 
             rqstr_id, 
             as_of_tms, 
             adjst_tms, 
             qty_cqty, 
             bkpg_curr_cde, 
             ent_proc_curr_cde, 
             last_chg_tms, 
             last_chg_usr_id, 
             data_src_id, 
             isid_oid) 
SELECT new_oid, 
       'EIS', 
       'EIS', 
       'GS0000001320', 
       '0020', 
       'B', 
       isid.instr_id, 
       'NONLATAM', 
       'BRSEOD', 
       sysdate + 1, 
       sysdate + 1, 
       '83872', 
       'USD', 
       'USD', 
       sysdate + 1, 
       'THAIAUTOMATION',
       'EIS', 
       isid.isid_oid 
FROM   ft_t_isid isid 
WHERE  iss_id IN ( 'TH0637010Y18', 'TH8319010Z14', 'TH3871010Z19',
                   'TH0264A10Z12', 'TH0375010Z14', 'TH0450010Y16', 'TH0999010Z11', 
                   'TH9597010015', 'TH0465010013', 'TH0015010018', 'TH1027010012', 
                   'TH0689010Z18', 'TH5097010000', 'TH0637010Y00', 'TH8319010Z06',
                   'TH3871010Z01', 'TH0264A10Z04', 'TH0375010Z06', 'TH0450010Y08',
                   'TH0999010Z03', 'TH9597010007', 'TH0465010005', 'TH0015010000',
                   'TH1027010004', 'TH0689010Z00')
       AND id_ctxt_typ = 'ISIN' 
       AND end_tms IS NULL 
       AND NOT EXISTS (SELECT 1 
                       FROM   ft_t_balh 
                       WHERE  rqstr_id = 'BRSEOD' 
                              AND end_tms IS NULL 
                              AND Trunc(as_of_tms) = Trunc(sysdate + 1) 
                              AND instr_id = isid.instr_id);

commit;