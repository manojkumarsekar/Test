--Insert new record into FIID with id_ctxt_typ='BRSTRDCNTCDE' for the given broker if not already present
INSERT INTO FT_T_FIID
(FIID_OID, INST_MNEM, FINS_ID_CTXT_TYP, FINS_ID, START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID, DATA_STAT_TYP,DATA_SRC_ID, GLOBAL_UNIQ_IND)
SELECT NEW_OID,(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME ='${TAIWAN_BROKER}' AND END_TMS IS NULL), 'BRSTRDCNTCDE',
'T_FIL-TW', SYSDATE, SYSDATE, 'TEST USER', 'ACTIVE', 'BRS','N'
FROM DUAL WHERE NOT EXISTS (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID = 'T_FIL-TW' AND FINS_ID_CTXT_TYP='BRSTRDCNTCDE' AND END_TMS IS NULL);

--Insert new record into FIID with id_ctxt_typ='BRSCNTCDE' for the given broker if not already present
INSERT INTO FT_T_FIID
(FIID_OID, INST_MNEM, FINS_ID_CTXT_TYP, FINS_ID, START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID, DATA_STAT_TYP,DATA_SRC_ID, GLOBAL_UNIQ_IND)
SELECT NEW_OID,(SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME ='${TAIWAN_BROKER}' AND END_TMS IS NULL), 'BRSCNTCDE',
'T_FIL-TW', SYSDATE, SYSDATE, 'TEST USER', 'ACTIVE', 'BRS','N'
FROM DUAL WHERE NOT EXISTS (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID = 'T_FIL-TW' AND FINS_ID_CTXT_TYP='BRSCNTCDE' AND END_TMS IS NULL);

commit;