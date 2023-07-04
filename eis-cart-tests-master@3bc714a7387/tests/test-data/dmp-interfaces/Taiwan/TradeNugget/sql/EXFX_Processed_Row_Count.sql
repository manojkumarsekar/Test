SELECT Count (1) AS EXFX_PROCESSED_ROW_COUNT
FROM   ft_t_exfx 
WHERE  to_curr_camt = '20098.36' 
       AND to_curr_cde = 'USD' 
       AND from_curr_camt = '296551236' 
       AND from_curr_cde = 'IDR' 
       AND near_leg_intbnk_crte = '14754.99673' 
       AND inverse_crte = '14754.9967300000' 
       AND exec_trd_id IN (SELECT exec_trd_id 
                           FROM   ft_t_extr 
                           WHERE  trd_id = '3204-2776_valid_trade' 
                                  AND exec_trn_cat_typ = 'TRD' 
                                  AND exec_trn_cat_sub_typ = 'I' 
                                  AND To_char (trd_dte, 'MM/DD/YYYY') = 
                                      '11/20/2018' 
                                  AND To_char (input_appl_tms, 
                                      'MM/DD/YYYY HH24:MI:SS') 
                                      = 
                                      '11/20/2018 00:24:11' 
                                  AND To_char (settle_dte, 'MM/DD/YYYY') = 
                                      '11/26/2018' 
                                  AND trd_curr_cde = 'JPY' 
                                  AND trd_cprc = '1054.0075' 
                                  AND trn_cde = 'BRSEOD' 
                                  AND trd_cqty = '-35000.1' 
                                  AND end_tms IS NULL) 