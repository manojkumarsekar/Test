DELETE ft_t_rsr1 WHERE ext_rsrsh_id in ('Test-Report-4160-A', 'Test-Report-4160-B', 'Test-Report-4160-C');

INSERT INTO ft_t_rsr1(rsr1_oid, ext_rsrsh_id, ext_rsrsh_pub_tms, data_src_id, start_tms, end_tms, last_chg_tms, last_chg_usr_id, ext_status, ext_rsrsh_cat, ext_last_prc, ext_trgt_prc_upper, ext_trgt_prc_lower, trn_cde, ext_rsrsh_expiry_dte)
VALUES (NEW_OID, 'Test-Report-4160-A', SYSDATE, 'EIS', SYSDATE, NULL, TRUNC(SYSDATE), 'EIS', 'ACTIVE', 'TW_DEQ_BS',  100, 140, 60, 'BUY', SYSDATE - 1);

INSERT INTO ft_t_rsr1(rsr1_oid, ext_rsrsh_id, ext_rsrsh_pub_tms, data_src_id, start_tms, end_tms, last_chg_tms, last_chg_usr_id, ext_status, ext_rsrsh_cat, ext_last_prc, ext_trgt_prc_upper, ext_trgt_prc_lower, trn_cde, ext_rsrsh_expiry_dte)
VALUES (NEW_OID, 'Test-Report-4160-B', SYSDATE, 'EIS', SYSDATE, NULL, TRUNC(SYSDATE), 'EIS', 'ACTIVE', 'TW_DEQ_BS',  100, 140, 60, 'BUY', SYSDATE);

INSERT INTO ft_t_rsr1(rsr1_oid, ext_rsrsh_id, ext_rsrsh_pub_tms, data_src_id, start_tms, end_tms, last_chg_tms, last_chg_usr_id, ext_status, ext_rsrsh_cat, ext_last_prc, ext_trgt_prc_upper, ext_trgt_prc_lower, trn_cde, ext_rsrsh_expiry_dte)
VALUES (NEW_OID, 'Test-Report-4160-C', SYSDATE, 'EIS', SYSDATE, NULL, TRUNC(SYSDATE), 'EIS', 'ACTIVE', 'TW_DEQ_BS',  100, 140, 60, 'BUY', SYSDATE+15);

COMMIT;