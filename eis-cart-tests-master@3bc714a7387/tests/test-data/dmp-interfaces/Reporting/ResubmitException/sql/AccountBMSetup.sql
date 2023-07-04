--INSERT PORTFOLIO
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','RESUBEXCPFL2'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'RESUBEXCPFL2');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'RESUBPFL02','EIS','EIS','GSRESUB000000002'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSRESUB000000002');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'RESUB002','RESUBPFL02','EIS','RESUBEXCPFL2',to_timestamp ('14/11/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'RESUB002');

--INSERT PORTFOLIO
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','RESUBEXCPFL3'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'RESUBEXCPFL3');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'RESUBPFL03','EIS','EIS','GSRESUB000000003'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSRESUB000000003');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'RESUB003','RESUBPFL03','EIS','RESUBEXCPFL3',to_timestamp ('14/11/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'RESUB003');

--INSERT BM
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT 'RESUB03BM',null,null,null, 'RESUB03'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'RESUB03');


INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID2,BNCHMRK_NME,VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT 'RESUBBM003','RESUB03BM','EIS','BMRESUB003','50% MSCI AC Wld Net Div TR + 50% BB Global Aggregate', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'RESUBBM003');

--CREATE PORTFOLIO-BM RELATIONSHIP
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'RESU003RL','RESUBPFL03','RESUB03BM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'RESU003RL');

commit;