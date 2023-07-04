--EISDEV-6374: When this feature file is executed on Prod copy in development environment, it works as expected. Some other feature file is end_dating and re-creating the E.1 Entity.
--Adding an Insert in FIGP with ative INST_MENM. Insert is added because this is configuration and not set up from any feed file

INSERT INTO ft_t_figp 
            (prnt_fins_grp_oid, 
             start_tms, 
             inst_mnem, 
             fins_grp_oid, 
             prt_purp_typ, 
             end_tms, 
             last_chg_tms, 
             last_chg_usr_id, 
             prt_desc, 
             data_stat_typ, 
             data_src_id, 
             figp_oid, 
             part_camt, 
             part_curr_cde, 
             part_cpct) 
SELECT (SELECT fins_grp_oid 
        FROM   ft_t_figr 
        WHERE  grp_nme = 'FAAIF'), 
       sysdate, 
       (SELECT inst_mnem 
        FROM   ft_t_fiid 
        WHERE  fins_id = '1' 
               AND fins_id_ctxt_typ = 'RCRLBULEID' 
               AND end_tms IS NULL), 
       NULL, 
       'MEMBER', 
       NULL, 
       sysdate, 
       'EIS:CSTM', 
       'FA AIF Participant', 
       'ACTIVE', 
       NULL, 
       new_oid, 
       NULL, 
       NULL, 
       NULL 
FROM   dual 
WHERE  NOT EXISTS (SELECT 1 
                   FROM   ft_t_figp 
                   WHERE  inst_mnem = (SELECT inst_mnem 
                                       FROM   ft_t_fiid 
                                       WHERE  fins_id = '1' 
                                              AND fins_id_ctxt_typ = 
                                                  'RCRLBULEID' 
                                              AND end_tms IS NULL));
commit;