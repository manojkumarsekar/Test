DECLARE 
    l_id VARCHAR2(20); 
    f_id VARCHAR2(20); 
    CURSOR c_local_frn IS 
	  WITH local_frn AS
	    (
	    select 'TH5097010018','TH5097010000' from dual union all
	    select 'TH0637010Y18','TH0637010Y00' from dual union all
	    select 'TH8319010Z14','TH8319010Z06' from dual union all
	    select 'TH3871010Z19','TH3871010Z01' from dual union all
	    select 'TH0264A10Z12','TH0264A10Z04' from dual union all
	    select 'TH0375010Z14','TH0375010Z06' from dual union all
	    select 'TH0450010Y16','TH0450010Y08' from dual union all
	    select 'TH0999010Z11','TH0999010Z03' from dual union all
	    select 'TH9597010015','TH9597010007' from dual union all
	    select 'TH0465010013','TH0465010005' from dual union all
	    select 'TH0015010018','TH0015010000' from dual union all
	    select 'TH1027010012','TH1027010004' from dual union all
	    select 'TH0689010Z18','TH0689010Z00' from dual
	    )
      SELECT * 
      FROM   local_frn; 
BEGIN 
    OPEN c_local_frn; 

    LOOP 
        FETCH c_local_frn INTO f_id, l_id; 

        EXIT WHEN c_local_frn%NOTFOUND; 

        INSERT INTO ft_t_ridf 
                    (rld_iss_feat_id, 
                     instr_id, 
                     start_tms, 
                     rel_typ, 
                     last_chg_tms, 
                     last_chg_usr_id, 
                     data_src_id, 
                     data_stat_typ) 
        SELECT new_oid, 
               (SELECT instr_id 
                FROM   ft_t_isid 
                WHERE  iss_id = f_id 
                       AND end_tms IS NULL 
                       AND id_ctxt_typ = 'ISIN'), 
               SYSDATE, 
               'DOMQUOT', 
               SYSDATE, 
               'AUTOMATION:FS_LS', 
               'EIS', 
               'ACTIVE' 
        FROM   dual 
        WHERE  NOT EXISTS (SELECT 1 
                           FROM   ft_t_ridf 
                           WHERE  instr_id = (SELECT instr_id 
                                              FROM   ft_t_isid 
                                              WHERE  iss_id = f_id 
                                                     AND end_tms IS NULL 
                                                     AND id_ctxt_typ = 'ISIN') 
                                  AND rel_typ = 'DOMQUOT' 
                                  AND end_tms IS NULL); 

        INSERT INTO ft_t_riss 
                    (riss_oid, 
                     rld_iss_feat_id, 
                     instr_id, 
                     part_units_typ, 
                     iss_part_rl_typ, 
                     last_chg_tms, 
                     last_chg_usr_id, 
                     data_src_id, 
                     data_stat_typ) 
        SELECT new_oid, 
               rld_iss_feat_id, 
               (SELECT instr_id 
                FROM   ft_t_isid 
                WHERE  iss_id = l_id 
                       AND end_tms IS NULL 
                       AND id_ctxt_typ = 'ISIN'), 
               'ALL', 
               'UNDLYING', 
               SYSDATE, 
               'AUTOMATION:FS_LS', 
               'EIS', 
               'ACTIVE' 
        FROM   ft_t_ridf A 
        WHERE  instr_id = (SELECT instr_id 
                           FROM   ft_t_isid 
                           WHERE  iss_id = f_id 
                                  AND end_tms IS NULL 
                                  AND id_ctxt_typ = 'ISIN') 
               AND rel_typ = 'DOMQUOT' 
               AND end_tms IS NULL 
               AND NOT EXISTS (SELECT 1 
                               FROM   ft_t_riss 
                               WHERE  instr_id = (SELECT instr_id 
                                                  FROM   ft_t_isid 
                                                  WHERE  iss_id = l_id 
                                                         AND end_tms IS NULL 
                                                         AND id_ctxt_typ = 
                                                             'ISIN') 
                                      AND rld_iss_feat_id = A.rld_iss_feat_id 
                                      AND end_tms IS NULL); 
    END LOOP; 

    COMMIT; 

    CLOSE c_local_frn; 
END;