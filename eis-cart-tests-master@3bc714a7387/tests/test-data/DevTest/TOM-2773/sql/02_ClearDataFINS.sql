delete ft_t_ffrl where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme in ('TESTFINS','HOUSE_CODE','MEMBER_CODE'));
delete ft_t_frip where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme in ('TESTFINS','HOUSE_CODE','MEMBER_CODE'));
delete ft_t_finr where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme in ('TESTFINS','HOUSE_CODE','MEMBER_CODE'));
delete ft_t_fiid where inst_mnem in(select inst_mnem from fT_t_fins where inst_nme in ('TESTFINS','HOUSE_CODE','MEMBER_CODE'));
delete ft_t_fins where inst_nme IN ('TESTFINS','HOUSE_CODE','MEMBER_CODE')