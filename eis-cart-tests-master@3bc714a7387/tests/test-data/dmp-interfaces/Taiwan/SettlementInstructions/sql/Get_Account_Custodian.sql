SELECT fins.INST_NME AS CUSTODIAN_NAME,acid.ACCT_ALT_ID AS PORTFOLIO_NAME,acct.acct_nme AS ACCOUNT_NAME from ft_t_acid acid
      inner join ft_t_acct acct
      on acct.acct_id = acid.acct_id
      inner join ft_t_frap frap
      on acid.acct_id = frap.acct_id
      inner join FT_T_FINS fins
      on frap.inst_mnem = fins.inst_mnem
      inner join ft_t_fiid fiid
      on fins.inst_mnem=fiid.inst_mnem
      where frap.FINSRL_TYP='CUSTDIAN'
      And fiid.FINS_ID_CTXT_TYP='INHOUSE'
      And acid.acct_id_ctxt_typ = 'CRTSID'
      And acid.end_tms is null
      AND ROWNUM = 1