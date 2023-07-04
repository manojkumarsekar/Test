DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','MM/dd/yyyy'));

DELETE ft_t_balh WHERE as_of_tms >= TO_DATE('${POS_DATE}','MM/dd/yyyy');

UPDATE ft_t_acgp
SET    end_tms = sysdate
WHERE  prnt_acct_grp_oid IN (SELECT acct_grp_oid
                             FROM   ft_t_acgr
                             WHERE  acct_grp_id IN ( 'ESI-ALL' ))
       AND acct_id IN (SELECT acct_id
                       FROM   ft_t_acid
                       WHERE  acct_alt_id IN ( '3186', '3223' ));

UPDATE ft_t_isid
SET    end_tms = sysdate
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id IN ( 'BES38WAE3', 'BES38VP25', 'BES38VPR0' )
                           AND id_ctxt_typ IN ( 'BCUSIP' )
                           AND end_tms IS NULL)
       AND id_ctxt_typ IN ( 'SEDOL', 'ISIN', 'CUSIP' );

INSERT INTO FT_T_FIGU (FIGU_OID,INST_MNEM,GU_ID,GU_TYP,GU_CNT,FINS_GU_PURP_TYP, START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,DATA_STAT_TYP,DATA_SRC_ID)
SELECT NEW_OID,'D89u13Qf81','TH','COUNTRY',1,'INCRPRTE', SYSDATE,SYSDATE,'AUTOMATION','ACTIVE','BRS'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM FT_T_FIGU WHERE INST_MNEM = 'D89u13Qf81' AND FINS_GU_PURP_TYP = 'INCRPRTE');

INSERT INTO FT_T_FIGU (FIGU_OID,INST_MNEM,GU_ID,GU_TYP,GU_CNT,FINS_GU_PURP_TYP, START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,DATA_STAT_TYP,DATA_SRC_ID)
SELECT NEW_OID,'D89u13Qf81','TH','COUNTRY',1,'DOMICILE', SYSDATE,SYSDATE,'AUTOMATION','ACTIVE','BRS'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM FT_T_FIGU WHERE INST_MNEM = 'D89u13Qf81' AND FINS_GU_PURP_TYP = 'DOMICILE');