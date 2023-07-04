
UPDATE ft_T_acid
SET end_tms = sysdate
WHERE acct_id IN
(
    SELECT acct_id
    FROM ft_t_acid
    WHERE acct_alt_id LIKE '3362%'
);

UPDATE ft_T_acct
SET acct_nme = 'Enddated-' ||  acct_nme
WHERE acct_nme = '3362_PORTFOLIO_TC1';

DELETE
FROM ft_t_aud1
WHERE ext_main_ent_nme = '3362_PORTFOLIO_TC1';

COMMIT;