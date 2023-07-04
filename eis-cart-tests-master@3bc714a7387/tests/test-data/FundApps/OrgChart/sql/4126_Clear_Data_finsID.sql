UPDATE ft_t_fiid  set  end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where fins_id in ('1397169','458005','SC210546','1404713','477356' )and  fins_id_ctxt_typ = 'RCRLBUCOM' and  last_chg_usr_id ='EIS_RCRLBU_ORG_CHART';

UPDATE ft_t_fiid  set   end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where fins_id in('1','81','30','32','40') and  fins_id_ctxt_typ = 'RCRLBULEID' and  last_chg_usr_id ='EIS_RCRLBU_ORG_CHART';

UPDATE ft_t_fins  set end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where inst_nme ='Prudential public limited company' and pref_fins_id_ctxt_typ = 'RCRLBUCOM' and PREF_FINS_ID='1397169' and LAST_CHG_USR_ID = 'EIS_RCRLBU_ORG_CHART';

UPDATE ft_t_fins  set end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where inst_nme ='PRUDENTIAL CORPORATION ASIA LIMITED' and pref_fins_id_ctxt_typ in ('RCRLBUCOM','RCRLBULEID')and PREF_FINS_ID in('458005','81') and LAST_CHG_USR_ID = 'EIS_RCRLBU_ORG_CHART';

UPDATE ft_t_fins  set end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where inst_nme ='PRUDENTIAL HOLDINGS LIMITED' and pref_fins_id_ctxt_typ in ('RCRLBUCOM','RCRLBULEID') and PREF_FINS_ID in ('SC210546','30')and LAST_CHG_USR_ID = 'EIS_RCRLBU_ORG_CHART';

UPDATE ft_t_fins  set end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where inst_nme ='PRUDENTIAL CORPORATION HOLDINGS LIMITED' and pref_fins_id_ctxt_typ in ('RCRLBUCOM','RCRLBULEID') and PREF_FINS_ID in ('32','1404713')and LAST_CHG_USR_ID = 'EIS_RCRLBU_ORG_CHART';

UPDATE ft_t_fins  set end_tms =(START_TMS-1),START_TMS=(START_TMS-1)
where inst_nme ='EASTSPRING INVESTMENTS (HONG KONG) LIMITED' and pref_fins_id_ctxt_typ = 'INHOUSE' and PREF_FINS_ID='ES-HK' and LAST_CHG_USR_ID = 'EIS_RCRLBU_ORG_CHART';
COMMIT