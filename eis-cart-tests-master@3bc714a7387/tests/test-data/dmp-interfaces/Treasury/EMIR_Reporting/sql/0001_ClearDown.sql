UPDATE ft_t_extr
SET end_tms = sysdate,
    trd_id = NEW_OID
WHERE trn_cde = 'PITLBRSEOD'
AND trd_id LIKE '%GT'
AND end_tms IS NULL;

COMMIT;