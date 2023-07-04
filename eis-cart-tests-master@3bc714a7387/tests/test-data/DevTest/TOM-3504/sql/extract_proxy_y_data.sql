SELECT ACID.ACCT_ALT_ID AS IRPID_Y,BNID.BNCHMRK_ID AS BENCHMARKCODE_Y, concat(bnid.bnchmrk_id,ISS_ID) AS BCUSIP_Y
FROM FT_T_BNCH BNCH
INNER JOIN FT_T_ABMR ABMR ON BNCH.BNCH_OID = ABMR.BNCH_OID AND ABMR.END_TMS IS NULL
INNER JOIN FT_T_ACID ACID ON ABMR.ACCT_ID = ACID.ACCT_ID AND ACID.ACCT_ID_CTXT_TYP = 'IRPID' AND ACID.END_TMS IS NULL
INNER JOIN FT_T_BNPT BNPT ON BNPT.PRNT_BNCH_OID = BNCH.BNCH_OID
INNER JOIN FT_T_ISID ISID ON BNPT.INSTR_ID = ISID.INSTR_ID AND ISID.ID_CTXT_TYP = 'BCUSIP' AND ISID.END_TMS IS NULL
LEFT OUTER JOIN FT_T_ISST ISST ON ISID.INSTR_ID = ISST.INSTR_ID AND STAT_DEF_ID = 'BRSBMSPX' AND ISST.STAT_CHAR_VAL_TXT = 'Y'
INNER JOIN FT_T_BNVL BNVL ON BNVL.BNPT_OID = BNPT.BNPT_OID AND bnvl.close_wgt_bmrk_crte IS NOT NULL
INNER JOIN FT_T_BNID BNID ON BNCH.BNCH_OID = BNID.BNCH_OID AND BNCHMRK_ID_CTXT_TYP = 'BRSBNCHID' AND SUBSTR (BNCHMRK_ID, 0, 3) = 'GMP'
WHERE TRUNC (BNVL.BNCHMRK_VAL_TMS) IN ( SELECT MAX (BNVL.BNCHMRK_VAL_TMS)
                                          FROM FT_T_BNCH BNCH
INNER JOIN FT_T_BNPT BNPT ON BNPT.PRNT_BNCH_OID = BNCH.BNCH_OID
INNER JOIN FT_T_BNVL BNVL ON BNVL.BNPT_OID = BNPT.BNPT_OID
INNER JOIN FT_T_BNID BNID ON BNID.BNCH_OID = BNCH.BNCH_OID AND   BNCHMRK_ID_CTXT_TYP = 'BRSBNCHID' AND   SUBSTR (BNCHMRK_ID, 0, 3) = 'GMP'
                                          WHERE TRUNC (BNVL.BNCHMRK_VAL_TMS) < TRUNC (SYSDATE)
) AND   EXISTS ( SELECT 1
                   FROM FT_T_ISST ISST
                   WHERE ISID.INSTR_ID = ISST.INSTR_ID AND   STAT_DEF_ID = 'BRSBMSPX' AND   ISST.STAT_CHAR_VAL_TXT = 'Y'
) AND   ROWNUM = 1