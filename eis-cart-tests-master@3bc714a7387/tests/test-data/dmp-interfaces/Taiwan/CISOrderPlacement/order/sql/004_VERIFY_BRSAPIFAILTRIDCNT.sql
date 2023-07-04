SELECT COUNT(*) AS BRSFAILTRIDCOUNT
    FROM FT_T_TRID
    WHERE MAIN_ENTITY_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = '${BCUSIP}' AND END_TMS IS NULL)
    AND MAIN_ENTITY_ID_CTXT_TYP = 'INSTR_ID'
    AND MAIN_ENTITY_TYP = 'ISSU'
    AND MAIN_ENTITY_TBL_TYP = 'ISSU'
    AND CRRNT_TRN_STAT_TYP = 'CLOSED'
    AND INPUT_MSG_TYP = 'EIS_MT_BRS_SECURITY_NEW'
    AND CRRNT_SEVERITY_CDE = 50
    AND JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT = 'BRS API Call Job')
      WHERE R=1)