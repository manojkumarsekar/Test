SELECT COUNT(*) AS REVORDERTRIDCOUNT FROM FT_T_TRID
    WHERE MAIN_ENTITY_ID in (SELECT AUOR_OID FROM FT_T_AUOR WHERE PREF_ORDER_ID = '225215' AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER' AND ACCT_ID IS NOT NULL  AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ORDERS')
    AND MAIN_ENTITY_ID_CTXT_TYP = 'AUOR_OID'
    AND MAIN_ENTITY_TYP = 'AUOR'
    AND MAIN_ENTITY_TBL_TYP = 'AUOR'
    AND CRRNT_SEVERITY_CDE = 0
    AND CRRNT_TRN_STAT_TYP = 'CLOSED'
    AND TRN_MSG_STAT_TYP = 'REVPEND'
    AND TRN_MSG_STAT_DESC LIKE '225215_${PORTFOLIOCRTSID}_${BCUSIP}_%_ACTIVE_%'
    AND JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT ='Publish Insight Report Job')
      WHERE R=1)