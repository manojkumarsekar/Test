SELECT
    COUNT(*) AS VERIFY_ISID_BOCI FROM FT_T_ISID WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '6073556' AND END_TMS IS NULL)
    AND ID_CTXT_TYP IN ('ISIN','SEDOL','BOCICODE')
AND   END_TMS IS NULL