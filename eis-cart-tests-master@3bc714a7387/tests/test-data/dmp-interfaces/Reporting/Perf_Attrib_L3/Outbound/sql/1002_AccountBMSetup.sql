-- TOM-5207 Portfolio and Benchmark set up for which WPEA and WCRI are created (IMNAME!=Eastspring (S) & (HK))

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS')
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'WPWC5207' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wpea SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS')
WHERE acct_sok_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'WPWC5207'
and DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','WPWC5207acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'WPWC5207acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'WPWC5207bn'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'WPWC5207bn');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'WPWC5207acctTest'),'EIS','WPWC5207', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'WPWC5207' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'WPWC5207bn'),'EIS','WPWC5207', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'WPWC5207' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'WPWC5207' AND DW_STATUS_NUM=1),(select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'WPWC5207' AND DW_STATUS_NUM=1),'BL3PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL3PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'WPWC5207' AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'WPWC5207' AND DW_STATUS_NUM=1),(select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'WPWC5207' AND DW_STATUS_NUM=1),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'WPWC5207' AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1);

commit;


-- TOM-5207 Portfolio and Benchmark set up for which WPEA is created and there is no WCRI

UPDATE ft_t_wpea SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS')
WHERE acct_sok_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'WP5207'
and DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','WP5207_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'WP5207_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'WP5207bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'WP5207bnh');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'WP5207_acctTest'),'EIS','WP5207', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'WP5207' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'WP5207bnh'),'EIS','WP5207', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'WP5207' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'WP5207_acctTest'),(select ACCT_SOK from ft_t_wack where BNCH_OID = 'WP5207bnh'),'BL3PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL3PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'WP5207' AND DW_STATUS_NUM=1)AND DW_STATUS_NUM=1);

commit;


-- TOM-5207 Portfolio and Benchmark set up for which WPEA and WCRI are created (IMNAME!=Eastspring (S) & (HK))

UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS')
WHERE acct_sok = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5207' and  DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

UPDATE ft_t_wpea SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${UPDATE_VAR_SYSDATE}','YYYYMMDD-HH24MISS') 
WHERE acct_sok_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5207' 
and DW_STATUS_NUM =1) and DW_STATUS_NUM =1;

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT new_oid,'EIS','EIS','tom5207_acctTest'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'tom5207_acctTest');

INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID,BNCH_OID)
SELECT new_oid,null,null,null, 'tom5207bnh'
from dual where not exists (select 1 from ft_t_wack where BNCH_OID = 'tom5207bnh');

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where dw_acct_id = 'tom5207_acctTest'),'EIS','TOM5207', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID10 = 'TOM5207' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID1, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,ENT_SHORT_NME)
SELECT new_oid,(select ACCT_SOK from ft_t_wack where BNCH_OID = 'tom5207bnh'),'EIS','TOM5207', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', 'EIS'
from dual where not exists (select 1 from FT_T_WACT where INTRNL_ID1 = 'TOM5207' AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'TOM5207' AND DW_STATUS_NUM=1),(select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'TOM5207' AND DW_STATUS_NUM=1),'BL3PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL3PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TOM5207' AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1);

INSERT INTO FT_T_WACR
(WACR_SOK, ACCT_SOK, REP_ACCT_SOK, RL_TYP, VERSION_START_TMSMP, VERSION_END_TMSMP, DW_STATUS_NUM,START_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID)
SELECT new_oid,(select ACCT_SOK from FT_T_WACT where INTRNL_ID10 = 'TOM5207' AND DW_STATUS_NUM=1),(select ACCT_SOK from FT_T_WACT where INTRNL_ID1 = 'TOM5207' AND DW_STATUS_NUM=1),'BL1PRIM', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1', to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'), 'AUTOTEST'
from dual where not exists (select 1 from FT_T_WACR where RL_TYP = 'BL1PRIM' and acct_sok in (select acct_sok from FT_T_WACT where INTRNL_ID10 = 'TOM5207' AND DW_STATUS_NUM=1) AND DW_STATUS_NUM=1);

commit;