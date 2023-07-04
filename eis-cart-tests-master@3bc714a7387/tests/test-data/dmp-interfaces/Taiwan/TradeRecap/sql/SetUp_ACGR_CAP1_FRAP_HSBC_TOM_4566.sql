INSERT INTO ft_t_acgr (
    acct_grp_oid,
    acct_grp_id,
    last_chg_tms,
    last_chg_usr_id,
    grp_purp_typ,
    start_tms,
    grp_nme,
    grp_desc,
    data_stat_typ,
    data_src_id
)
    SELECT
        NEW_OID,
        'TWFACAP1',
        SYSDATE,
        '4566_ACGR_TEST',
        'UNIVERSE',
        SYSDATE,
        'TWFACAP1',
        'Taiwan Fund Admin CAP 1',
        'ACTIVE',
        'EITW'
    FROM
        dual
    WHERE
        NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP1'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP1'
        );


INSERT INTO ft_t_acgp (
    prnt_acct_grp_oid,
    start_tms,
    acct_grp_oid,
    acct_org_id,
    acct_bk_id,
    acct_id,
    end_tms,
    part_rank_num,
    part_typ,
    prt_purp_typ,
    last_chg_tms,
    last_chg_usr_id,
    curr_cde,
    prt_desc,
    data_stat_typ,
    data_src_id,
    part_camt,
    part_cpct,
    acgp_oid
)
    SELECT
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP1'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP1'
        ),
        SYSDATE,
        (
            SELECT
                acct_grp_oid
            FROM
                ft_t_acgr
            WHERE
                grp_nme = 'TWFACAP1'
                AND   grp_purp_typ = 'UNIVERSE'
                AND   acct_grp_id = 'TWFACAP1'
        ),
        'EIS',
        'EIS',
        acct_id,
        NULL,
        NULL,
        NULL,
        'MEMBER',
        SYSDATE,
        '4566_ACGP_TEST',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        new_oid
    FROM
        ft_t_acid acid
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id = 'Test4566'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acgp acgp
            WHERE
                prnt_acct_grp_oid = (
                    SELECT
                        acct_grp_oid
                    FROM
                        ft_t_acgr
                    WHERE
                        grp_nme = 'TWFACAP1'
                        AND   grp_purp_typ = 'UNIVERSE'
                        AND   acct_grp_id = 'TWFACAP1'
                )
                AND   acid.acct_id = acgp.acct_id
        );

INSERT INTO ft_t_frap (
    frap_oid,
    inst_mnem,
    finsrl_typ,
    org_id,
    bk_id,
    acct_id,
    prt_purp_typ,
    start_tms,
    end_tms,
    last_chg_tms,
    last_chg_usr_id,
    part_curr_cde,
    prt_desc,
    data_stat_typ,
    data_src_id,
    part_camt,
    part_cpct,
    prim_rel_ind,
    rel_stat_typ,
    rel_stat_tms,
    finsrl_acct_id,
    fins_inst_mnem,
    claimable_ind,
    rel_approved_ind,
    rel_approved_tms,
    participant_id
)
    SELECT
        NEW_OID,
        'lq6O01>I81',
        'FUNDADM',
        'EIS',
        'EIS',
        acct_id,
        NULL,
        SYSDATE,
        NULL,
        SYSDATE,
        '4566_FRAP_TEST',
        NULL,
        NULL,
        'ACTIVE',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM
        ft_t_acid acid
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id = 'Test4566'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_frap frap
            WHERE
                frap.inst_mnem = 'lq6O01>I81'
                AND   frap.finsrl_typ = 'FUNDADM'
                AND   acid.acct_id = frap.acct_id
        );

INSERT INTO ft_t_acid (
    acid_oid,
    org_id,
    bk_id,
    acct_id,
    entr_org_id,
    subd_org_id,
    subdiv_id,
    acct_id_ctxt_typ,
    acct_alt_id,
    start_tms,
    end_tms,
    last_chg_tms,
    last_chg_usr_id,
    data_stat_typ,
    data_src_id,
    acct_cross_ref_id,
    acct_id_stat_typ,
    acct_id_stat_tms
)
    SELECT
        NEW_OID,
        'EIS',
        'EIS',
        acct_id,
        NULL,
        NULL,
        NULL,
        'BRSFUNDID',
        '3205',
        SYSDATE,
        NULL,
        SYSDATE,
        '4566_ACID_TEST',
        NULL,
        'BRS',
        acct_cross_ref_id,
        NULL,
        NULL
    FROM
        ft_t_acid acid1
    WHERE
        acct_id_ctxt_typ = 'CRTSID'
        AND   acct_alt_id = 'Test4566'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_acid acid2
            WHERE
                acid2.acct_id_ctxt_typ = 'BRSFUNDID'
                AND   acid2.acct_alt_id = '3205'
                AND   acid1.acct_id = acid2.acct_id
        );

INSERT INTO ft_t_opch (
    opch_oid,
    instr_id,
    data_stat_typ,
    data_src_id,
    last_chg_tms,
    last_chg_usr_id,
    call_put_typ,
    exer_typ,
    strke_typ,
    strke_start_tms,
    strke_end_tms,
    strke_fq_qty,
    strke_fq_dy_typ,
    strke_fq_sp_typ,
    strke_fix_bas_typ,
    strke_fix_typ,
    strke_rte_meth_typ,
    asian_opt_typ,
    asian_avg_fq_typ,
    asian_avg_typ,
    asian_wag_ind,
    first_mon_dte,
    mon_end_dte,
    barr_direct_typ,
    mon_fq_qty,
    lback_strke_typ,
    adjst_cntrct_ind,
    barr_typ,
    option_typ,
    strke_prc_quote_typ,
    opt_fut_ver_num,
    cash_flow_id,
    deletion_reason_cde,
    one_instr_instance_ind,
    opt_dlv_cde,
    underly_unit_typ,
    strke_cprc,
    strke_fix_aj_crte,
    mn_strke_cprc,
    mx_strke_cprc,
    secnd_strke_cprc,
    norm_strke_cprc,
    barr_1_cprc,
    barr_2_cprc,
    barr_rebate1_camt,
    barr_rebate2_camt,
    lback_mnmx_cpct,
    lback_mnmx_camt,
    actl_cntrct_size_camt,
    underly_unit_cqty,
    rte_set_typ,
    strke_prc_curr_cde,
    secnd_strke_prc_curr_cde,
    secnd_strke_prc_quote_typ,
    opt_exer_ind,
    sched_avail_ind,
    nxt_avg_tms,
    obs_prd_dy_cnt,
    rebate_pay_ind,
    barr_reached_ind,
    flex_opt_prd_start_tms,
    flex_opt_prd_end_tms,
    cmpnd_opt_strke_crte,
    corr_coef_crte,
    dbl_avg_rte_aj_camt,
    ref_amt_curr_cde,
    clq_opt_glbl_cap_ind,
    clq_opt_glbl_floor_ind,
    clq_opt_lcl_cap_ind,
    clq_opt_lcl_floor_ind,
    risk_valu_ind,
    fwd_start_opt_typ,
    vars_peacs_dsr_obs_cnt,
    curr_pair_quote_typ,
    dlv_tms,
    avg_unit_curr_cde,
    start_tms,
    end_tms,
    strke_prc_bas_instr_id,
    exotic_opt_typ,
    digital_opt_typ,
    lback_opt_typ,
    cmpnd_opt_typ,
    opt_trdng_meth_typ,
    opt_trdng_strategy_typ,
    underly_exp_dte,
    euro_fut_opt_ind,
    underly_curr_cde,
    opt_eff_dte,
    opt_up_front_cpct,
    opt_up_front_pct_curr_cde,
    opt_trdng_strtegy_leg_cnt,
    renew_fq_sp_typ,
    prcng_session_typ,
    cntrct_typ,
    asian_tail_pd_start_dte,
    asian_tail_pd_end_dte,
    undly_cntrct_exp_typ,
    cntrct_dlv_mth_typ,
    opt_expiration_typ,
    opt_settle_session_typ,
    short_pos_asgn_meth_typ,
    penny_pilot_ind,
    settle_on_open_ind,
    opt_close_only_ind,
    non_std_option_ind,
    warrant_typ,
    exotic_parm_cde,
    exotic_parm_val,
    opt_tenor_typ,
    opt_fut_ver2_num,
    undly_curr_pair_txt
)
    SELECT
        new_oid,
        instr_id,
        NULL,
        'TEST_4566',
        SYSDATE,
        'TEST_4566',
        'P',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        12.5,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM
        ft_t_isid isid
    WHERE
        isid.iss_id = 'S64967003'
        AND   isid.id_ctxt_typ = 'BCUSIP'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_opch opch
            WHERE
                isid.instr_id = opch.instr_id
                AND   opch.call_put_typ = 'P'
        );

INSERT INTO ft_t_opch (
    opch_oid,
    instr_id,
    data_stat_typ,
    data_src_id,
    last_chg_tms,
    last_chg_usr_id,
    call_put_typ,
    exer_typ,
    strke_typ,
    strke_start_tms,
    strke_end_tms,
    strke_fq_qty,
    strke_fq_dy_typ,
    strke_fq_sp_typ,
    strke_fix_bas_typ,
    strke_fix_typ,
    strke_rte_meth_typ,
    asian_opt_typ,
    asian_avg_fq_typ,
    asian_avg_typ,
    asian_wag_ind,
    first_mon_dte,
    mon_end_dte,
    barr_direct_typ,
    mon_fq_qty,
    lback_strke_typ,
    adjst_cntrct_ind,
    barr_typ,
    option_typ,
    strke_prc_quote_typ,
    opt_fut_ver_num,
    cash_flow_id,
    deletion_reason_cde,
    one_instr_instance_ind,
    opt_dlv_cde,
    underly_unit_typ,
    strke_cprc,
    strke_fix_aj_crte,
    mn_strke_cprc,
    mx_strke_cprc,
    secnd_strke_cprc,
    norm_strke_cprc,
    barr_1_cprc,
    barr_2_cprc,
    barr_rebate1_camt,
    barr_rebate2_camt,
    lback_mnmx_cpct,
    lback_mnmx_camt,
    actl_cntrct_size_camt,
    underly_unit_cqty,
    rte_set_typ,
    strke_prc_curr_cde,
    secnd_strke_prc_curr_cde,
    secnd_strke_prc_quote_typ,
    opt_exer_ind,
    sched_avail_ind,
    nxt_avg_tms,
    obs_prd_dy_cnt,
    rebate_pay_ind,
    barr_reached_ind,
    flex_opt_prd_start_tms,
    flex_opt_prd_end_tms,
    cmpnd_opt_strke_crte,
    corr_coef_crte,
    dbl_avg_rte_aj_camt,
    ref_amt_curr_cde,
    clq_opt_glbl_cap_ind,
    clq_opt_glbl_floor_ind,
    clq_opt_lcl_cap_ind,
    clq_opt_lcl_floor_ind,
    risk_valu_ind,
    fwd_start_opt_typ,
    vars_peacs_dsr_obs_cnt,
    curr_pair_quote_typ,
    dlv_tms,
    avg_unit_curr_cde,
    start_tms,
    end_tms,
    strke_prc_bas_instr_id,
    exotic_opt_typ,
    digital_opt_typ,
    lback_opt_typ,
    cmpnd_opt_typ,
    opt_trdng_meth_typ,
    opt_trdng_strategy_typ,
    underly_exp_dte,
    euro_fut_opt_ind,
    underly_curr_cde,
    opt_eff_dte,
    opt_up_front_cpct,
    opt_up_front_pct_curr_cde,
    opt_trdng_strtegy_leg_cnt,
    renew_fq_sp_typ,
    prcng_session_typ,
    cntrct_typ,
    asian_tail_pd_start_dte,
    asian_tail_pd_end_dte,
    undly_cntrct_exp_typ,
    cntrct_dlv_mth_typ,
    opt_expiration_typ,
    opt_settle_session_typ,
    short_pos_asgn_meth_typ,
    penny_pilot_ind,
    settle_on_open_ind,
    opt_close_only_ind,
    non_std_option_ind,
    warrant_typ,
    exotic_parm_cde,
    exotic_parm_val,
    opt_tenor_typ,
    opt_fut_ver2_num,
    undly_curr_pair_txt
)
    SELECT
        new_oid,
        instr_id,
        NULL,
        'TEST_4566',
        SYSDATE,
        'TEST_4566',
        'C',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        12.5,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM
        ft_t_isid isid
    WHERE
        isid.iss_id = 'BPM1U4B12'
        AND   isid.id_ctxt_typ = 'BCUSIP'
        AND   end_tms IS NULL
        AND   NOT EXISTS (
            SELECT
                1
            FROM
                ft_t_opch opch
            WHERE
                isid.instr_id = opch.instr_id
                AND   opch.call_put_typ = 'C'
        );

UPDATE ft_t_iscl
SET    cl_value = 'FUND',
       clsf_oid = (SELECT clsf_oid
                   FROM   ft_t_incl
                   WHERE  indus_cl_set_id = 'SECGROUP'
                          AND cl_value = 'FUND'
                          AND end_tms IS NULL)
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id = 'BPM1U4B12'
                           AND end_tms IS NULL)
       AND indus_cl_set_id = 'SECGROUP'
       AND cl_value <> 'FUND';

COMMIT;