
UPDATE ft_t_extr set end_tms = sysdate,trd_id = NEW_OID where trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' and end_tms is null ;
DELETE FROM ft_t_acgp WHERE end_tms IS NULL AND prnt_acct_grp_oid IN (SELECT acct_grp_oid FROM ft_t_acgr WHERE acct_grp_id = 'SSDRPRDEXCLPORT' AND end_tms IS NULL);

COMMIT;