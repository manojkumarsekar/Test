delete fT_T_fpid where fins_pro_id in('def123','abc123');
delete fT_T_fpgu where fpro_oid in (select fpro_oid from ft_T_fpro where fins_pro_id in ('tarunkumar.trivedi@eastspring.com','nitin.mahajan@eastspring.com'));
delete ft_t_adtp where fpro_oid in (select fpro_oid from ft_T_fpro where fins_pro_id in ('tarunkumar.trivedi@eastspring.com','nitin.mahajan@eastspring.com'));
delete ft_T_fpro where fins_pro_id in ('tarunkumar.trivedi@eastspring.com','nitin.mahajan@eastspring.com')