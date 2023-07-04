INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT NEW_OID,null,null,null, 'tom4971bnf'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'tom4971bnf');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT NEW_OID,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom4971bnf'),'EIS','ALASPSTSTl3F', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'ALASPSTSTl3F' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT NEW_OID,(select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'ABTHMF' AND DW_STATUS_NUM=1),(select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'ALASPSTSTl3F' AND DW_STATUS_NUM=1),'BL3PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL3PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'ABTHMF' AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1);

commit;