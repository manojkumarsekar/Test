update
    ft_t_iscl
set
    clsf_oid = (
        select
            clsf_oid
        from
            ft_t_incl
        where
            indus_cl_set_id = 'RDMSCTYP'
            and cl_value = 'COM'
            and end_tms is null
    ),
    cl_value = 'COM'
where
    instr_id in (
        select
            instr_id
        from
            ft_t_isid
        where
            iss_id = 'B2NJ7Z1'
            and id_ctxt_typ = 'SEDOL'
            and end_tms is null
    )
    and indus_cl_set_id = 'RDMSCTYP'
    and END_TMS is null;

commit;