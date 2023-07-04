SELECT
    COUNT(*) AS VERIFY_ISID_ESKOR FROM FT_T_ISID WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'AN8068571086' AND END_TMS IS NULL)
    AND ID_CTXT_TYP IN ('ISIN','SEDOL','EIMKORCDE')
AND   END_TMS IS NULL