delete fT_T_trcp where inst_mnem in (select inst_mnem from ft_t_fins where inst_nme ='TESTFINS_1');
delete ft_t_finr where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme ='TESTFINS_1');
delete ft_t_fiid where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme ='TESTFINS_1');
delete ft_t_fins where inst_nme ='TESTFINS_1'