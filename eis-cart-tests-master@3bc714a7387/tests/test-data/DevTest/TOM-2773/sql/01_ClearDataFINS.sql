DELETE ft_t_fiid WHERE inst_mnem IN (SELECT inst_mnem FROM fT_t_fins WHERE inst_nme='TC-01-FINS');
DELETE ft_t_fins WHERE inst_nme='TC-01-FINS'