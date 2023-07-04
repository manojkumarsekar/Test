--Benchmark Creation

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT 'L1AUVALBM',null,null,null, 'AUTOBMVAL'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'AUTOBMVAL');


INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID2,BNCHMRK_NME,VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT 'L1VALBM01','L1AUVALBM','EIS','BMGRFEE006','50% MSCI AC Wld Net Div TR + 50% BB Global Aggregate', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VALBM01');


--Portfolio 1 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL01'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL01');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL01','EIS','EIS','GSAUTOVAL0000001'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000001');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL001','L1AUVAL01','EIS','AUTO_TST_PFL_VAL01',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL001');


--Portfolio 1 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL1','L1AUVAL01','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL1');


--Portfolio 2 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL02'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL02');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL02','EIS','EIS','GSAUTOVAL0000002'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000002');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL002','L1AUVAL02','EIS','AUTO_TST_PFL_VAL02',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL002');


--Portfolio 2 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL2','L1AUVAL02','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL2');


--Portfolio 3 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL03'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL03');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL03','EIS','EIS','GSAUTOVAL0000003'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000003');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL003','L1AUVAL03','EIS','AUTO_TST_PFL_VAL03',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL003');


--Portfolio 3 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL3','L1AUVAL03','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL3');


--Portfolio 4 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL04'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL04');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL04','EIS','EIS','GSAUTOVAL0000004'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000004');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL004','L1AUVAL04','EIS','AUTO_TST_PFL_VAL04',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL004');


--Portfolio 4 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL4','L1AUVAL04','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL4');


--Portfolio 5 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL05'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL05');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL05','EIS','EIS','GSAUTOVAL0000005'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000005');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL005','L1AUVAL05','EIS','AUTO_TST_PFL_VAL05',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL005');


--Portfolio 5 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL5','L1AUVAL05','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL5');


--Portfolio 6 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL06'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL06');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL06','EIS','EIS','GSAUTOVAL0000006'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000006');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL006','L1AUVAL06','EIS','AUTO_TST_PFL_VAL06',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL006');


--Portfolio 6 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL6','L1AUVAL06','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL6');


--Portfolio 7 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL07'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL07');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL07','EIS','EIS','GSAUTOVAL0000007'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000007');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL007','L1AUVAL07','EIS','AUTO_TST_PFL_VAL07',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL007');


--Portfolio 7 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL7','L1AUVAL07','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL7');


--Portfolio 8 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL08'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL08');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL08','EIS','EIS','GSAUTOVAL0000008'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000008');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL008','L1AUVAL08','EIS','AUTO_TST_PFL_VAL08',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL008');


--Portfolio 8 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL8','L1AUVAL08','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL8');


--Portfolio 9 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL09'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL09');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL09','EIS','EIS','GSAUTOVAL0000009'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000009');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL009','L1AUVAL09','EIS','AUTO_TST_PFL_VAL09',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL009');


--Portfolio 9 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOVAL9','L1AUVAL09','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOVAL9');


--Portfolio 10 Creation
INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL_VAL10'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL_VAL10');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUVAL10','EIS','EIS','GSAUTOVAL0000010'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTOVAL0000010');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1VAL010','L1AUVAL10','EIS','AUTO_TST_PFL_VAL10',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1VAL010');


--Portfolio 10 - BM association
INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT 'L1AUTOV10','L1AUVAL10','L1AUVALBM','BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where WACR_SOK = 'L1AUTOV10');


commit;