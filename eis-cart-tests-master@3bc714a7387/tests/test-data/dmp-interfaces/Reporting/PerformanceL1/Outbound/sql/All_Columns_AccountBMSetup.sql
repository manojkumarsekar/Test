UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BENT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBENT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','tom5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'tom5237_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'tom5237bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'tom5237bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'tom5237sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'tom5237sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5237_acctTest'),'EIS','TOM5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TOM5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5237bnh'),'EIS','BENT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BENT5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5237sbn'),'EIS','SEBENT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBENT5237' AND DW_STATUS_NUM=1);


INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TOM5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TOM5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BONT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBONT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','TOT5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'TOT5237_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TOT5237bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TOT5237bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TOT5237sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TOT5237sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TOT5237_acctTest'),'EIS','TOT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TOT5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TOT5237bnh'),'EIS','BONT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BONT5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TOT5237sbn'),'EIS','SEBONT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBONT5237' AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TSM5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BSNT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBSNT5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','TSM5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'TSM5237_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TSM5237bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TSM5237bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TSM5237sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TSM5237sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TSM5237_acctTest'),'EIS','TSM5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TSM5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5237bnh'),'EIS','BSNT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BSNT5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5237sbn'),'EIS','SEBSNT5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBSNT5237' AND DW_STATUS_NUM=1);


INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TSM5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TSM5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TSM5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TSM5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TSM5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TST5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;
 
UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'BSST5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SEBSST5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','TST5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'TST5237_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TST5237bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TST5237bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'TST5237sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'TST5237sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'TST5237_acctTest'),'EIS','TST5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TST5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TST5237bnh'),'EIS','BSST5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'BSST5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'TST5237sbn'),'EIS','SEBSST5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SEBSST5237' AND DW_STATUS_NUM=1);

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok in (select acct_sok from ft_t_wact where intrnl_id10 in ('A5237','B5237','C5237','D5237','E5237','F5237','G5237','H5237','I5237','J5237','K5237','L5237') and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'PA5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id1 = 'SA5237' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

update FT_T_WACR 
SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
where RL_TYP in ('BL1PRIM','BL1SECON') and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 in  ('A5237','B5237','C5237','D5237','E5237','F5237','G5237','H5237','I5237','J5237','K5237','L5237') AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','A5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'A5237_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'A5237bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'A5237bnh' );

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'A5237sbn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'A5237sbn' );

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'A5237_acctTest'),'EIS','A5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'A5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'EIS','PA5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'PA5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'EIS','SA5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'SA5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'A5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'A5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'A5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'A5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','B5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'B5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'B5237_acctTest'),'EIS','B5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'B5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'B5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'B5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','C5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'C5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'C5237_acctTest'),'EIS','C5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'C5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'C5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'C5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);	

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','D5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'D5237_acctTest');


INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'D5237_acctTest'),'EIS','D5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'D5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'D5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'D5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','E5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'E5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'E5237_acctTest'),'EIS','E5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'E5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'E5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'E5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'E5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'E5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','F5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'F5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'F5237_acctTest'),'EIS','F5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'F5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'F5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'F5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','G5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'G5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'G5237_acctTest'),'EIS','G5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'G5237' AND DW_STATUS_NUM=1);


INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'G5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'G5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','H5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'H5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'H5237_acctTest'),'EIS','H5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'H5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','I5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'I5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'I5237_acctTest'),'EIS','I5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'I5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'I5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'I5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'I5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'I5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','J5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'J5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'J5237_acctTest'),'EIS','J5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'J5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'J5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237bnh'),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'J5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','K5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'K5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'K5237_acctTest'),'EIS','K5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'K5237' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'K5237_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'A5237sbn'),'BL1SECON', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1SECON' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'K5237' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);		

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','L5237_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'L5237_acctTest');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'L5237_acctTest'),'EIS','L5237', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'L5237' AND DW_STATUS_NUM=1);

commit;