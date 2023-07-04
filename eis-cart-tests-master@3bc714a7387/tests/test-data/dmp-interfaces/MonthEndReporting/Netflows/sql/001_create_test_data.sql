INSERT INTO ft_t_wfxr (fxrt_sok, srce_curr_cde, trgt_curr_cde, fx_typ, fx_tenor_typ, fx_dtdf_sok, fx_tms, version_start_tmsmp, fx_rte_valid_typ, unitary_curr_cde, data_src_id, fx_crte, fx_srce_typ, dw_status_num, version_end_tmsmp, end_of_prd_typ, last_chg_tms, last_chg_usr_id)
SELECT NEW_OID(), s.srce_curr_cde, s.trgt_curr_cde, s.fx_typ, s.fx_tenor_typ, TO_CHAR(TO_DATE('${PREV_ME_LAST_BD}','yyyy-mon-dd'),'yyyymmdd'), TO_DATE('${PREV_ME_LAST_BD}','yyyy-mon-dd'), TO_DATE('${MS_DATE}','yyyy-mon-dd'), s.fx_rte_valid_typ, s.unitary_curr_cde, s.data_src_id, s.fx_crte, s.fx_srce_typ, s.dw_status_num, TO_DATE('${ME_DATE}','yyyy-mon-dd'), s.end_of_prd_typ, SYSDATE, s.last_chg_usr_id
FROM ft_t_wfxr s WHERE TRUNC(s.fx_tms) = TO_DATE('31-Jan-2020','dd-mon-yyyy') 
AND s.end_of_prd_typ = 'DA';
INSERT INTO ft_t_wfxr (fxrt_sok, srce_curr_cde, trgt_curr_cde, fx_typ, fx_tenor_typ, fx_dtdf_sok, fx_tms, version_start_tmsmp, fx_rte_valid_typ, unitary_curr_cde, data_src_id, fx_crte, fx_srce_typ, dw_status_num, version_end_tmsmp, end_of_prd_typ, last_chg_tms, last_chg_usr_id)
SELECT NEW_OID(), s.srce_curr_cde, s.trgt_curr_cde, s.fx_typ, s.fx_tenor_typ, TO_CHAR(TO_DATE('${ME_LAST_BD}','yyyy-mon-dd'),'yyyymmdd'), TO_DATE('${ME_LAST_BD}','yyyy-mon-dd'), TO_DATE('${MS_DATE}','yyyy-mon-dd'), s.fx_rte_valid_typ, s.unitary_curr_cde, s.data_src_id, s.fx_crte, s.fx_srce_typ, s.dw_status_num, TO_DATE('${ME_DATE}','yyyy-mon-dd'), s.end_of_prd_typ, SYSDATE, s.last_chg_usr_id
FROM ft_t_wfxr s WHERE TRUNC(s.fx_tms) = TO_DATE('06-Feb-2020','dd-mon-yyyy') 
AND s.end_of_prd_typ = 'DA';
INSERT INTO ft_t_wact (acct_data_sok, acct_sok, acct_nme, version_start_tmsmp, version_end_tmsmp, rptg_prd_start_dte, rptg_prd_end_dte)
SELECT NEW_OID(), k.acct_sok, c.acct_nme, TO_DATE('${MS_DATE}','yyyy-mon-dd'), TO_DATE('${ME_DATE}','yyyy-mon-dd'), TO_DATE('${MS_DATE}','yyyy-mon-dd'), TO_DATE('${ME_DATE}','yyyy-mon-dd')
FROM   ft_t_wack k, ft_t_wact c WHERE k.dw_acct_id = 'ANARMF' AND c.acct_sok = k.acct_sok AND c.rptg_prd_end_dte = TO_DATE('29-Feb-2020','dd-mon-yyyy');