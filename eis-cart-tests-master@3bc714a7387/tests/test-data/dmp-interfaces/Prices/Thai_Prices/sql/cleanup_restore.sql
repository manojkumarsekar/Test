delete from ft_t_balh where last_chg_usr_id = 'THAIAUTOMATION';

delete from ft_t_inlm where last_chg_usr_id = 'THAIAUTOMATION';

update ft_t_isid set end_tms=sysdate where last_chg_usr_id = 'THAIAUTOMATION';

insert
   into ft_t_inlm
 select *
   from ft_t_inlm_bkp;

drop table ft_t_inlm_bkp;

update
ft_t_ispc set prc_valid_typ = 'DERIVE' where prc_valid_typ = 'THAIAUTO';

update ft_t_ispc set prc_valid_typ = 'UNVERIFD',LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
where prc_typ = '003' AND prc_valid_typ = 'IGNORE' AND LAST_CHG_USR_ID = 'THAIAUTOMATION'
and data_src_id = 'BB' and instr_id in (select instr_id from ft_t_isid where iss_id in ('TH3871010Z01','TH0999010Z03','TH0015010000','TH0689010Z00') and end_tms is null);

update ft_t_ispc set prc_valid_typ = 'DERIVE' WHERE  prc_typ = 'IGNORE' AND prc_srce_typ = 'ESTHF' AND prc_valid_typ = 'VALID'
AND prcng_meth_typ = 'ESITHP' and instr_id in (select instr_id from ft_t_isid where iss_id = 'TH0689010Z18' and end_tms is null);

commit;