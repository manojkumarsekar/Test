INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL004_NoReturn'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL004_NoReturn');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUTO004','EIS','EIS','GSAUTO0000000004'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTO0000000004');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1ADSP004','L1AUTO004','EIS','AUTO_TST_PFL004_NoReturn',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1ADSP004');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT 'L1AUTO04BM',null,null,null, 'AUTOBNCH04'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'AUTOBNCH04');


INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID2,BNCHMRK_NME,VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT 'L1ADSBM004','L1AUTO04BM','EIS','BMGRFEE008','50% MSCI AC Wld Net Div TR + 50% BB Global Aggregate', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1ADSBM004');


INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTO04RL','L1AUTO004','L1AUTO04BM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTO04RL');

commit;