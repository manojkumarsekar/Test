SELECT
    COUNT(*) AS VERIFY_ISID_ESJP FROM FT_T_ISID WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '2113382' AND END_TMS IS NULL)
    AND ID_CTXT_TYP IN ('ISIN','ESJPCODE')
AND   END_TMS IS NULL