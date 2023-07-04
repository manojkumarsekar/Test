UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BENT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBENT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','tom5239_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'tom5239_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'tom5239bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'tom5239bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'tom5239sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'tom5239sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5239_acctTest'),'EIS','TOM5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TOM5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5239bnh'),'EIS','BENT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BENT5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5239sbn'),'EIS','SEBENT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBENT5239' AND DW_STATUS_NUM=1);


INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5239_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5239bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TOM5239' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5239_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5239sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TOM5239' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BONT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBONT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','TOT5239_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'TOT5239_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TOT5239bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TOT5239bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TOT5239sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TOT5239sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TOT5239_acctTest'),'EIS','TOT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TOT5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TOT5239bnh'),'EIS','BONT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BONT5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TOT5239sbn'),'EIS','SEBONT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBONT5239' AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TSM5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BSNT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBSNT5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','TSM5239_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'TSM5239_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TSM5239bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TSM5239bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TSM5239sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TSM5239sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TSM5239_acctTest'),'EIS','TSM5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TSM5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5239bnh'),'EIS','BSNT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BSNT5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5239sbn'),'EIS','SEBSNT5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBSNT5239' AND DW_STATUS_NUM=1);


INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TSM5239_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5239bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TSM5239' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TSM5239_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5239sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TSM5239' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TST5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BSST5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBSST5239' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','TST5239_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'TST5239_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TST5239bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TST5239bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TST5239sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TST5239sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TST5239_acctTest'),'EIS','TST5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TST5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TST5239bnh'),'EIS','BSST5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BSST5239' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TST5239sbn'),'EIS','SEBSST5239', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBSST5239' AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'A5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'B5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'C5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'D5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'E5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'PA5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SA5247' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','A5247_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'A5247_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'A5247bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'A5247bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'A5247sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'A5247sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'A5247_acctTest'),'EIS','A5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'A5247' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247bnh'),'EIS','PA5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'PA5247' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247sbn'),'EIS','SA5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SA5247' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'A5247_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'A5247' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'A5247_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'A5247' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','B5247_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'B5247_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'B5247_acctTest'),'EIS','B5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'B5247' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','C5247_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'C5247_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'C5247_acctTest'),'EIS','C5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'C5247' AND DW_STATUS_NUM=1);


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','D5247_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'D5247_acctTest');


INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'D5247_acctTest'),'EIS','D5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'D5247' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'D5247_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'D5247' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'D5247_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'D5247' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','E5247_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'E5247_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'E5247_acctTest'),'EIS','E5247', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'E5247' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'E5247_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'E5247' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'E5247_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5247sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'E5247' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

commit;