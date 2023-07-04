DELETE ft_t_accr WHERE rep_acct_id IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID LIKE '%TOM3947%');
UPDATE ft_t_acid SET start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE acct_id IN
(SELECT acct_id FROM ft_t_acid WHERE acct_id_ctxt_typ = 'RDMID' AND acct_alt_Id LIKE '%TOM3947%' AND end_tms IS NULL);
COMMIT;