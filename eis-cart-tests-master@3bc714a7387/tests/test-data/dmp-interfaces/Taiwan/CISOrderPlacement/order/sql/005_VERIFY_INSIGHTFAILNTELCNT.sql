SELECT COUNT(*) AS INSIGHTFAILNTELCOUNT FROM FT_T_NTEL
    WHERE   NOTFCN_ID = 60024
    AND MSG_SEVERITY_CDE = 50
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND CHAR_VAL_TXT = 'Insight webservice call failed to get Insight report for CrossRefoid null with Status Code 5003 and error text as Invalid user name or password'
    AND LAST_CHG_TRN_ID IN
      (SELECT TRID.TRN_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT = 'Publish Insight Report Job') JBLG, FT_T_TRID TRID
      WHERE JBLG.JOB_ID = TRID.JOB_ID AND R=1)