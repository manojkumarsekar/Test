DELETE ft_t_acid WHERE acct_id IN (SELECT acct_id FROM ft_t_acct WHERE acct_nme LIKE 'TWTST%');
DELETE ft_t_acct WHERE acct_nme LIKE 'TWTST%';

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST1', SYSDATE, 'OPEN', 'TWTST1OID', SYSDATE, 'TOM-3395', 'TWTST1', 'TW TEST PORTFOLIO 1 MAIN (WITH SPLIT AND HEDGE)');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST1', 'CRTSID', 'TWTST1', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST1OID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST1', 'SITCAFNDID', 'TWTST1', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST1OID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST1S', SYSDATE, 'OPEN', 'TWTST1SOID', SYSDATE, 'TOM-3395', 'TWTST1S', 'TW TEST PORTFOLIO 1 SPLIT');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST1S', 'CRTSID', 'TWTST1_S', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST1SOID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST1S', 'SITCAFNDID', 'TWTST1_S', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST1SOID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST1H', SYSDATE, 'OPEN', 'TWTST1HOID', SYSDATE, 'TOM-3395', 'TWTST1H', 'TW TEST PORTFOLIO 1 HEDGE');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST1H', 'CRTSID', 'TWTST1_USD', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST1HOID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST1H', 'SITCAFNDID', 'TWTST1_USD', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST1HOID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST2', SYSDATE, 'OPEN', 'TWTST2OID', SYSDATE, 'TOM-3395', 'TWTST2', 'TW TEST PORTFOLIO 2 MAIN (WITH SPLIT BUT NO HEDGE)');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST2', 'CRTSID', 'TWTST2', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST2OID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST2', 'SITCAFNDID', 'TWTST2', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST2OID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST2S', SYSDATE, 'OPEN', 'TWTST2SOID', SYSDATE, 'TOM-3395', 'TWTST2S', 'TW TEST PORTFOLIO 2 SPLIT');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST2S', 'CRTSID', 'TWTST2_S', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST2SOID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST2S', 'SITCAFNDID', 'TWTST2_S', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST2SOID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST3', SYSDATE, 'OPEN', 'TWTST3OID', SYSDATE, 'TOM-3395', 'TWTST3', 'TW TEST PORTFOLIO 3 MAIN (NO SPLIT AND NO HEDGE)');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST3', 'CRTSID', 'TWTST3', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST3OID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST3', 'SITCAFNDID', 'TWTST3', SYSDATE, SYSDATE, 'TOM-3395', 'TWTST3OID');

/* Statements for TOM-4692 */

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST4', SYSDATE, 'OPEN', 'TWTST4OID', SYSDATE, 'TOM-4692', 'TWTST4', 'TW TEST PORTFOLIO 4 MAIN');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST4', 'CRTSID', 'TWTST4', SYSDATE, SYSDATE, 'TOM-4692', 'TWTST4OID');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST4', 'SITCAFNDID', 'SITCATWTST4', SYSDATE, SYSDATE, 'TOM-4692', 'TWTST4OID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST4S', SYSDATE, 'OPEN', 'TWTST4SOID', SYSDATE, 'TOM-4692', 'TWTST4S', 'TW TEST PORTFOLIO 4 SPLIT');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST4S', 'CRTSID', 'TWTST4_S', SYSDATE, SYSDATE, 'TOM-4692', 'TWTST4SOID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST4EQS', SYSDATE, 'OPEN', 'TWTST4QOID', SYSDATE, 'TOM-4692', 'TWTST4EQS', 'TW TEST PORTFOLIO 4 EQUITY SPLIT');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST4EQS', 'CRTSID', 'TWTST4_EQ_S', SYSDATE, SYSDATE, 'TOM-4692', 'TWTST4QOID');

INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme, acct_desc)
VALUES ('EIS', 'EIS', 'TWTST4FIS', SYSDATE, 'OPEN', 'TWTST4FOID', SYSDATE, 'TOM-4692', 'TWTST4FIS', 'TW TEST PORTFOLIO 4 FIXED INCOME SPLIT');

INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
VALUES (NEW_OID, 'EIS', 'EIS', 'TWTST4FIS', 'CRTSID', 'TWTST4_FI_S', SYSDATE, SYSDATE, 'TOM-4692', 'TWTST4FOID');