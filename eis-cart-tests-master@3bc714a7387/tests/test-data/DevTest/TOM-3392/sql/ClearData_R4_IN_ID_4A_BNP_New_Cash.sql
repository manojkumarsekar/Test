delete from ft_t_etmg where exec_trd_id in(select exec_trd_id from ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate));

delete from ft_t_exst where exec_trd_id in(select exec_trd_id from ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate));

delete from ft_t_etid where exec_trd_id in(select exec_trd_id from ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate));

delete from ft_t_etcl where exec_trd_id in(select exec_trd_id from ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate));

delete from ft_t_etcm where exec_trd_id in(select exec_trd_id from ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate));

delete from ft_t_trcp where exec_trd_id in(select exec_trd_id from ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate));

delete from  ft_t_extr where trn_cde='EIS_BNP_DMP_INTRADAY_CASH_TRANSACTION' AND trunc(last_chg_tms) = trunc(sysdate);

commit;