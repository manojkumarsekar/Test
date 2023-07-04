DELETE FROM FT_T_ACST
WHERE  ACCT_ID IN (SELECT ACCT_ID from FT_T_ACID WHERE ACCT_ALT_ID='TT56' AND END_TMS IS NULL)
AND STAT_DEF_ID='ESUNPLTF';

INSERT INTO FT_T_ACST (STAT_ID, STAT_DEF_ID, ACCT_ORG_ID, ACCT_BK_ID, ACCT_ID, START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID, STAT_CHAR_VAL_TXT)
(SELECT NEW_OID, 'ESUNPLTF', 'EIS', 'EIS', ACCT_ID, SYSDATE, SYSDATE, 'AUTOMATION', 'Y' FROM FT_T_ACID A WHERE ACCT_ID_CTXT_TYP = 'CRTSID'
AND ACCT_ALT_ID = 'TT56' AND END_TMS IS NULL AND NOT EXISTS (SELECT 1 FROM FT_T_ACST WHERE A.ACCT_ID = ACCT_ID AND STAT_DEF_ID = 'ESUNPLTF'
AND STAT_CHAR_VAL_TXT = 'Y'));
COMMIT