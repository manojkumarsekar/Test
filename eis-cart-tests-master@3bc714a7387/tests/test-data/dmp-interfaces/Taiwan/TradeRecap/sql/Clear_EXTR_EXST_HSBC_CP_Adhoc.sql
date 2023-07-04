UPDATE FT_T_ACCR SET END_TMS = SYSDATE WHERE ACCT_ID IN
(select ACCT_ID from ft_T_EXTR where trd_id in ('4744-4744-01','4834-4834_01')
AND END_TMS IS NULL) and ORG_ID = 'EIS' and BK_ID = 'EIS' and end_tms is null;
delete ft_T_exst where exec_trd_id in (select exec_trd_id from ft_T_extr where  TRD_ID in ('4744-4744-01','4834-4834_01') and end_tms is null) and data_Src_id='HSBC';
UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('4744-4744-01','4834-4834_01') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('4744-4744-01','4834-4834_01') AND END_TMS IS NULL;
UPDATE FT_T_ACID SET END_TMS = SYSDATE WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID in ( 'TW-MAIN-SITCA-1','TW-MAIN-SITCA-2') and end_tms is null);
Commit;