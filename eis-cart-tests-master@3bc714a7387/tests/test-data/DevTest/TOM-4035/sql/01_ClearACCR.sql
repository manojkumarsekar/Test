delete ft_T_accr where acct_id in(select acct_id from fT_T_acct where acct_nme='share4035');
commit;