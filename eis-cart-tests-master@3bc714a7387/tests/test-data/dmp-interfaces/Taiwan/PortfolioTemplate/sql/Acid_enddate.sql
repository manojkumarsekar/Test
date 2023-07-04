UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_TWDA' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_TWDB' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_USDA' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_USDB' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_AUDA' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_AUDB' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_ZARA' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_ZARB' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_CNYA' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_CNYB' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT32_TWD' AND end_tms IS NULL);

UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT27' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT27_S' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_S' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TD00095' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_USD' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_CNY' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_AUD' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_ZAR' AND end_tms IS NULL);
UPDATE ft_t_accr SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  REP_ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT32' AND end_tms IS NULL);


UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_TWDA' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_TWDB' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_USDA' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_USDB' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_AUDA' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_AUDB' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_ZARA' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_ZARB' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_CNYA' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_CNYB' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT32_TWD' AND end_tms IS NULL);

UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT27' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT27_S' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_S' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TD00095' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_USD' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_CNY' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_AUD' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_ZAR' AND end_tms IS NULL);
UPDATE ft_t_acde SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT32' AND end_tms IS NULL);


UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT27' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT27_S' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_S' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TD00095' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_USD' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_CNY' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_AUD' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT56_ZAR' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCT_ALT_ID = 'TT32' AND end_tms IS NULL);


UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_TWDA' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_TWDB' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_USDA' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_USDB' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_AUDA' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_AUDB' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_ZARA' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_ZARB' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_CNYA' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT56_CNYB' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'RDMID' AND ACCT_ALT_ID = 'TT32_TWD' AND end_tms IS NULL);

UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621331S' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621330C' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621330E' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621330F' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621330G' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621330I' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '38621330J' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCUNIBUSNUM' AND ACCT_ALT_ID = '48885958' AND end_tms IS NULL);

UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO28' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO31' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO32' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO33' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO34' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO41' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO42' AND end_tms IS NULL);
UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE WHERE  ACCT_ID IN (SELECT ACCT_ID FROM ft_t_acid WHERE ACCT_ID_CTXT_TYP = 'SCSITCAFNDID' AND ACCT_ALT_ID = 'DIO09' AND end_tms IS NULL);

COMMIT;