INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT NEW_OID,'EIS','EIS','AUTO_TST_PFL007_NoBM'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'AUTO_TST_PFL007_NoBM');


INSERT INTO FT_T_WACK
(ACCT_SOK, ORG_ID, BK_ID, DW_ACCT_ID)
SELECT 'L1AUTO007','EIS','EIS','GSAUTO0000000007'
from dual where not exists (select 1 from ft_t_wack where dw_acct_id = 'GSAUTO0000000007');


INSERT INTO FT_T_WACT
(ACCT_DATA_SOK, ACCT_SOK, BK_NME, INTRNL_ID10,VERSION_START_TMSMP,  VERSION_END_TMSMP, DW_STATUS_NUM)
SELECT 'L1ADSP007','L1AUTO007','EIS','AUTO_TST_PFL007_NoBM',to_timestamp ('21/06/19 10:45:17.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),to_timestamp ('31/12/99 12:00:00.000000000', 'dd/mm/rr hh24:mi:ss.ff9'),'1'
from dual where not exists (select 1 from FT_T_WACT where ACCT_DATA_SOK = 'L1ADSP007');

commit;