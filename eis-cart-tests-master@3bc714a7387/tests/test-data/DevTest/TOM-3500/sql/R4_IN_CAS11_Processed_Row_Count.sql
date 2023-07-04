SELECT Count(exec_trd_id) AS PROCESSED_ROW_COUNT FROM ft_t_extr
 WHERE trn_cde = 'ESIICASHTXN'
 AND exec_trn_cat_typ = 'MISC'
 AND trn_cde = 'ESIICASHTXN'
 AND Trunc(trd_dte) IN ('21-Jun-2018', '22-Jun-2018', '25-Jun-2018', '27-Jun-2018', '29-Jun-2018')
 AND Trunc(settle_dte) IN ('20-Jun-2018', '21-Jun-2018', '26-Jun-2018', '28-Jun-2018', '30-Jun-2018')
 AND data_src_id = 'ESII'
 AND exec_trn_cat_typ = 'MISC'
 AND exec_trn_cat_sub_typ = 'MFEE'
 AND trd_legend_txt = 'TOM-3500 TICKET AUTOMATED TESTING'
 AND acct_org_id = 'EIS'
 AND acct_bk_id = 'EIS'
 AND acct_id IN
 (
     SELECT acct_id
     FROM   ft_t_acid
     WHERE  acct_alt_id IN ( 'NDSICF', 'ADPSEF' )
     AND acct_id_ctxt_typ = 'CRTSID'
     AND end_tms IS NULL
 )