insert into
    ft_t_fist (
        stat_id,
        stat_def_id,
        inst_mnem,
        start_tms,
        last_chg_tms,
        last_chg_usr_id,
        stat_char_val_txt,
        data_src_id
    )
select
    new_oid,
    'F13FNO',
    inst_mnem,
    sysdate,
    sysdate,
    'EISDEV7294',
    'EISDEV7294_F13FNO',
    'EIS'
from
    ft_t_fiid fiid
where
    fins_id_ctxt_typ = 'RCRLBULEID'
    and fins_id in ('50','199','372')
    and end_tms is null
    and not exists (
        select
            1
        from
            ft_t_fist
        where
            inst_mnem = fiid.inst_mnem
            and stat_def_id = 'F13FNO'
            and end_tms is null
    );

insert into
    ft_t_fist (
        stat_id,
        stat_def_id,
        inst_mnem,
        start_tms,
        last_chg_tms,
        last_chg_usr_id,
        stat_char_val_txt,
        data_src_id
    )
select
    new_oid,
    'F13FCIK',
    inst_mnem,
    sysdate,
    sysdate,
    'EISDEV7294',
    'EISDEV7294_F13FCIK',
    'EIS'
from
    ft_t_fiid fiid
where
    fins_id_ctxt_typ = 'RCRLBULEID'
    and fins_id in ('50','199','372')
    and end_tms is null
    and not exists (
        select
            1
        from
            ft_t_fist
        where
            inst_mnem = fiid.inst_mnem
            and stat_def_id = 'F13FCIK'
            and end_tms is null
    );

update
    ft_t_madr
set
    city_nme = 'EISDEV7294_CITY'
where
    mail_addr_id in (
        select
            mail_addr_id
        from
            ft_t_fiid fiid,
            ft_t_ccrf ccrf,
            ft_t_adtp adtp
        where
            fiid.fins_id_ctxt_typ = 'RCRLBULEID'
            and fiid.fins_id in ('50', '199', '372')
            and fiid.inst_mnem = ccrf.fins_inst_mnem
            and ccrf.cntl_cross_ref_oid = adtp.cntl_cross_ref_oid
            and adtp.addr_typ = 'BUSINESS'
            and ccrf.end_tms is null
            and adtp.end_tms is null
            and fiid.end_tms is null
    );

update
    ft_t_madr
set
    cntry_nme = 'EISDEV7294_COUNTRY'
where
    mail_addr_id in (
        select
            mail_addr_id
        from
            ft_t_fiid fiid,
            ft_t_ccrf ccrf,
            ft_t_adtp adtp
        where
            fiid.fins_id_ctxt_typ = 'RCRLBULEID'
            and fiid.fins_id in ('50', '199', '372')
            and fiid.inst_mnem = ccrf.fins_inst_mnem
            and ccrf.cntl_cross_ref_oid = adtp.cntl_cross_ref_oid
            and adtp.addr_typ = 'BUSINESS'
            and ccrf.end_tms is null
            and adtp.end_tms is null
            and fiid.end_tms is null
    );

update
    ft_t_madr
set
    postal_cde = 'EISDEV7294_POSTAL'
where
    mail_addr_id in (
        select
            mail_addr_id
        from
            ft_t_fiid fiid,
            ft_t_ccrf ccrf,
            ft_t_adtp adtp
        where
            fiid.fins_id_ctxt_typ = 'RCRLBULEID'
            and fiid.fins_id in ('50', '199', '372')
            and fiid.inst_mnem = ccrf.fins_inst_mnem
            and ccrf.cntl_cross_ref_oid = adtp.cntl_cross_ref_oid
            and adtp.addr_typ = 'BUSINESS'
            and ccrf.end_tms is null
            and adtp.end_tms is null
            and fiid.end_tms is null
    );

commit;