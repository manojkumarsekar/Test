UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID ='4691-4691' AND END_TMS IS NULL;
UPDATE FT_T_ACID SET END_TMS = SYSDATE WHERE ACCT_ALT_ID = 'Test4691' AND END_TMS IS NULL;
commit;