SELECT COUNT(*) AS VERIFY_ISSU
        FROM FT_T_ISSU
        WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '6054603' AND ID_CTXT_TYP = 'MNGCODE' AND END_TMS IS NULL)