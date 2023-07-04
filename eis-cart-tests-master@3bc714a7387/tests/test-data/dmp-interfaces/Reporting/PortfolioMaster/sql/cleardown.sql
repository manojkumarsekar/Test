UPDATE ft_t_acid SET END_TMS = SYSDATE-1, START_TMS = SYSDATE-1 WHERE acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Test5123%' and end_tms is null);
UPDATE ft_t_acid SET END_TMS = SYSDATE-1, START_TMS = SYSDATE-1 WHERE acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Test5123_YBNCH%' and end_tms is null);
UPDATE ft_t_acid SET END_TMS = SYSDATE-1, START_TMS = SYSDATE-1 WHERE acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Share5123%' and end_tms is null);
UPDATE ft_t_acid SET END_TMS = SYSDATE-1, START_TMS = SYSDATE-1 WHERE acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Test5139%' and end_tms is null);
UPDATE ft_t_acid SET END_TMS = SYSDATE-1, START_TMS = SYSDATE-1 WHERE acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Share5139%' and end_tms is null);

COMMIT;