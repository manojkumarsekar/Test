SELECT COUNT(0) AS BALH_COUNT
FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
WHERE  BALH.INSTR_ID = ISID.INSTR_ID
AND    ISID.ID_CTXT_TYP = 'BCUSIP'
AND    ISID.iss_id IN ('49446R109','880890108','S43543503','SBFWB6B86','S63683601')
AND    ISID.END_TMS IS NULL
AND    ISID.ISS_ID IS NOT NULL
AND    BALH.RQSTR_ID = 'BRSEOD'
AND    BALH.AS_OF_TMS IN (SELECT  MAX(AS_OF_TMS) FROM FT_T_BALH WHERE RQSTR_ID = 'BRSEOD')
AND    BALH.ACCT_ID = ACID.ACCT_ID
AND    ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
AND    ACID.END_TMS IS NULL
AND    ACID.ACCT_ALT_ID IN ('${PORTFOLIO_CRTS_1}','${PORTFOLIO_CRTS_2}')