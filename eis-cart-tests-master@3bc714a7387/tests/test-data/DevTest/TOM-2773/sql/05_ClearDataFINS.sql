delete ft_t_frip where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme IN ('TEST_SECURITY'));
delete ft_t_finr where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme IN ('TEST_SECURITY'));
delete ft_t_fiid where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme IN ('TEST_SECURITY'));
delete ft_t_fins where inst_nme IN ('TEST_SECURITY')