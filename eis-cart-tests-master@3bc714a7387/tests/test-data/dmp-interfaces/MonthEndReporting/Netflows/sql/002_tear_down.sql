DELETE ft_t_wtrd WHERE rptg_prd_end_dte = TO_DATE('${ME_DATE}','yyyy-mon-dd');
DELETE ft_t_wact WHERE rptg_prd_end_dte = TO_DATE('${ME_DATE}','yyyy-mon-dd');
DELETE ft_t_wfxr WHERE fx_tms >= TO_DATE('${MS_DATE}','yyyy-mon-dd');