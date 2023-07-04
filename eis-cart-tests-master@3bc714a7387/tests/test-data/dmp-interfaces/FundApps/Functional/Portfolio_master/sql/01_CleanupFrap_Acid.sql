
UPDATE ft_t_FRAP set end_tms =sysdate-1 where acct_id in (select acct_id from fT_T_acid where acct_alt_id='Test4280')and end_tms is null;

UPDATE ft_t_acid set end_tms =sysdate-1 where acct_id in (select acct_id from fT_T_acid where acct_alt_id='Test4280')and end_tms is null;


 COMMIT