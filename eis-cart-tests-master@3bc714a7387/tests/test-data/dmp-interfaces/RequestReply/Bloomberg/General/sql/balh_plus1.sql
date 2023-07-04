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
       'BBGAUTOMATION',
       'EIS',
       isid.isid_oid
FROM   ft_t_isid isid
WHERE  iss_id IN ( 'BBG002C8F78','BBG000BM86R7')
       AND id_ctxt_typ = 'BBGLOBAL'
       AND end_tms IS NULL
       AND NOT EXISTS (SELECT 1
                       FROM   ft_t_balh
                       WHERE  rqstr_id = 'BRSEOD'
                              AND end_tms IS NULL
                              AND Trunc(as_of_tms) = Trunc(sysdate + 1)
                              AND instr_id = isid.instr_id);

commit;