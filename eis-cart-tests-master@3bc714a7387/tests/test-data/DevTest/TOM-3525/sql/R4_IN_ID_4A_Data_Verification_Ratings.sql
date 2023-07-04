SELECT     Count(1) AS ISRT_COUNT
FROM       ft_t_isrt isrt
inner join ft_t_isid isid on isrt.instr_id = isid.instr_id AND isid.id_ctxt_typ='EISLSTID'
where      isrt.data_redistributor_id = 'ICE APEX'
AND        isrt.data_src_id='ICE APEX'
AND        isrt.data_stat_typ='ACTIVE'
AND        trunc(isrt.last_chg_tms) = trunc(SYSDATE)
AND        trunc(isrt.start_tms) = trunc(SYSDATE)
AND isrt.end_tms is null
AND isid.end_tms is null
AND        ( (
                                 isrt.orig_data_prov_id = 'RAM'
                      AND        isrt.rtng_eff_tms = to_date('15/08/2018', 'DD/MM/YYYY')
                      AND        isrt.rtng_symbol_txt='A1'
                      AND        isid.iss_id='ESL7418182')
           OR         (
                                 isrt.orig_data_prov_id = 'RAM'
                      AND        isrt.rtng_eff_tms = to_date('15/08/2018', 'DD/MM/YYYY')
                      AND        isrt.rtng_symbol_txt='A2'
                      AND        isid.iss_id='ESL4608988')
           OR         (
                                 isrt.orig_data_prov_id = 'RAM'
                      AND        isrt.rtng_eff_tms = to_date('15/08/2018', 'DD/MM/YYYY')
                      AND        isrt.rtng_symbol_txt='A3'
                      AND        isid.iss_id='ESL2741151')
           OR         (
                                 isrt.orig_data_prov_id = 'MARC'
                      AND        isrt.rtng_eff_tms = to_date('15/08/2018', 'DD/MM/YYYY')
                      AND        isrt.rtng_symbol_txt='A'
                      AND        isid.iss_id='ESL7418182')
           OR         (
                                 isrt.orig_data_prov_id = 'MARC'
                      AND        isrt.rtng_eff_tms = to_date('15/08/2018', 'DD/MM/YYYY')
                      AND        isrt.rtng_symbol_txt='AA-IS'
                      AND        isid.iss_id='ESL4608988')
           OR         (
                                 isrt.orig_data_prov_id = 'MARC'
                      AND        isrt.rtng_eff_tms = to_date('15/08/2018', 'DD/MM/YYYY')
                      AND        isrt.rtng_symbol_txt='AAA'
                      AND        isid.iss_id='ESL2741151')
           )