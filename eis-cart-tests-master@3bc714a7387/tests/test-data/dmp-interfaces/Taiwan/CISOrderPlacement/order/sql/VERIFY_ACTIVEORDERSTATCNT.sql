SELECT COUNT(*) AS ACTIVEORDERSTATCNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID  = '${ORDNUM}'
    AND AOST.ORDER_STAT_TYP = 'NEWSENT'
    AND GEN_CNT = ( SELECT MAX (GEN_CNT) FROM FT_T_AOST AOST1 WHERE AOST1.AUOR_OID = AUOR.AUOR_OID)