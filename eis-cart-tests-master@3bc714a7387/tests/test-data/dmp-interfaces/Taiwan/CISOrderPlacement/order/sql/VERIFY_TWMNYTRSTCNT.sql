 SELECT COUNT(*) AS MONEYTRUSIDCOUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = '${BCUSIP}' AND END_TMS IS NULL)
    AND ID_CTXT_TYP = 'TWMNYTRST'
    AND ISS_ID = '1435'