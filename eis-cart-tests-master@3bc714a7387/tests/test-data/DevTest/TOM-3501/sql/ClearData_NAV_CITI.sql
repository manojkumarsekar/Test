delete fT_T_accv where acct_id in (select acct_id from fT_T_acid where acct_alt_id='NDRIFN');