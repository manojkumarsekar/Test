WITH TABL_1 AS
(
    SELECT ACCT_ID AS ACID_ACCT_ID
    FROM FT_T_ACID
    WHERE ACCT_ID_CTXT_TYP='BNPPRTID'
    AND ACCT_ALT_ID = '${VAR_ACCT_ID}'
),
TABL_2 AS
(
    SELECT ACCT_ID AS BALH_ACCT_ID
    FROM FT_T_BALH
    WHERE BALH_OID='${BALH_OID}'
)
SELECT CASE WHEN A.ACID_ACCT_ID = B.BALH_ACCT_ID THEN 'PASS' ELSE 'FAIL' END as ACCT_ID_CHECK,A.ACID_ACCT_ID, B.BALH_ACCT_ID
FROM TABL_1 A
   CROSS JOIN TABL_2 B