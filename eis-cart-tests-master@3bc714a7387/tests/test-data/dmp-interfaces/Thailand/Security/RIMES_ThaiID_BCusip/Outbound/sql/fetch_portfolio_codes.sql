SELECT
    acct_alt_id as PORTFOLIO_CRTS_1
FROM
    ft_t_acid
where
    acct_id_ctxt_typ = 'CRTSID'
    AND end_tms IS NULL
    and rownum = 1
    and acct_id in (
        select
            acct_id
        from
            ft_t_acgr acgr,
            ft_t_acgp acgp
        where
            acgr.acct_grp_id = 'ESIB-AG'
            and acgr.acct_grp_oid = acgp.prnt_acct_grp_oid
            and acgr.end_tms is null
            and acgp.end_tms is null
    )