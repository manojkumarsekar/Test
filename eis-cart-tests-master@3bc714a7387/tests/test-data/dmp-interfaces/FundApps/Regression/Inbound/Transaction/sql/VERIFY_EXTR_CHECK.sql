    select count (*) as VERIFY_EXECTRD
    from fT_T_extr
    where trd_id='${TRD_ID}'
    and TRN_CDE='${TRN_CDE}'
    AND TRD_DTE = TO_DATE('${TRD_DTE}','DD/MM/YYYY')
    and trd_curr_cde='${TRD_CUR_CDE}'
    and trd_cqty='${TRD_CQT}'
    and trd_cprc='${TRD_PRZ}'
    and trn_sub_typ='${TRN_SUB_TYP}'
    And Instr_id in
                    (
                        select instr_id
                        from fT_T_isid
                        where iss_id='${Security_ID}'
                        and end_tms is null
                        and id_ctxt_typ in ('ISIN','SEDOL','CUSIP','${ID_CTXT_TYPE}')
                    )

