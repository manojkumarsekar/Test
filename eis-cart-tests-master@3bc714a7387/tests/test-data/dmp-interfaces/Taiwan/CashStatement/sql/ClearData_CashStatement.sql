DELETE from ft_t_actr
    where ACCT_ID IN
    (
      select ACCT_ID from ft_t_acid
      where ACCT_ALT_ID='${PORTFOLIO_NAME}'
    );
    COMMIT