update
    ft_t_isid
set
    start_tms = sysdate - 10,
    end_tms = sysdate,
    last_chg_tms = sysdate
where
    iss_id = 'B2NJ7Z1'
    and id_ctxt_typ = 'SEDOL'
    and end_tms is null;

commit;