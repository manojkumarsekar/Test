
-- For the purpose of automated test, AGPEFJ_TEST is not a valid IRPID hence it is not expected to be in ACID table.
UPDATE ft_t_acid
SET end_tms = sysdate,
    last_chg_tms = sysdate,
    last_chg_usr_id = 'TOM-3559 Automated Test'
WHERE acct_id_ctxt_typ = 'IRPID'
AND acct_alt_id = 'AGPEFJ_TEST'
AND end_tms IS NULL;

-- For the purpose of automated test, AKEINS is a valid IRPID but it's corresponding BRSFUNDID is not expected in ACID table.
UPDATE ft_t_acid
SET end_tms = sysdate,
    last_chg_tms = sysdate,
    last_chg_usr_id = 'TOM-3559 Automated Test'
WHERE acct_id_ctxt_typ IN ( 'ESPORTCDE', 'ALTCRTSID', 'CRTSID' )
AND end_tms IS NULL
AND acct_id =
(
    SELECT acct_id
    FROM ft_t_acid
    WHERE acct_id_ctxt_typ = 'IRPID'
    AND acct_alt_id = 'AKEINS'
    AND end_tms IS NULL
);

COMMIT;