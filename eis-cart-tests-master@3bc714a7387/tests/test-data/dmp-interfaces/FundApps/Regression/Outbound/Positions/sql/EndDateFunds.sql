UPDATE FT_T_ACID ACID set end_tms =sysdate-1, start_tms=sysdate-2
WHERE ACID.ACCT_ID_CTXT_TYP IN ('BOCICODE','KOREAID','ESJPCODE','MNGCODE','TMBAMCDE','PPMJNAMCDE','WFOECODE','EISLSTID')
AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_FUND';
COMMIT
