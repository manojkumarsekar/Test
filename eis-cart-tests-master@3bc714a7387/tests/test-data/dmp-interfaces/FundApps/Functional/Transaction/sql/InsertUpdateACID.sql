insert into ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
    select NEW_OID, org_id, bk_id, acct_id, 'ALTCRTSID', '2', SYSDATE, SYSDATE, 'EISDEV-6234-2', acct_cross_ref_id
    FROM ft_t_acid WHERE acct_id_ctxt_typ = 'IRPID' and acct_alt_id = '2'
				and not exists (select 1 from ft_t_acid WHERE acct_id_ctxt_typ = 'ALTCRTSID' and acct_alt_id = '2');

update ft_t_acid set acct_alt_id = 'EISDEV-6234-2' where acct_id_ctxt_typ = 'IRPID' and acct_alt_id = '2';