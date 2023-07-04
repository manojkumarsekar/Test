UPDATE FT_T_ACID
SET END_TMS = NULL
WHERE ACCT_ID IN
    (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID IN
            ('ALDAEFE','ALDAEEDY','ALEMAFE','ALVNEFJ')
        AND END_TMS IS NOT NULL
    );