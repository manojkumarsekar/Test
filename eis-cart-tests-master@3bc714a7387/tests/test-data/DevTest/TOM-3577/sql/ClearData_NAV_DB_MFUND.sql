delete fT_T_accv where acct_id in (select acct_id from fT_T_acid where acct_alt_id='MFPM0002') and data_src_id='DB';
delete fT_T_accv where acct_id in (select acct_id from fT_T_acid where acct_alt_id='MLTDED')  and data_src_id='MFUND';
delete fT_T_accv where acct_id in (select acct_id from fT_T_acid where acct_alt_id='MLSHLEQ') and data_src_id='MFUND';