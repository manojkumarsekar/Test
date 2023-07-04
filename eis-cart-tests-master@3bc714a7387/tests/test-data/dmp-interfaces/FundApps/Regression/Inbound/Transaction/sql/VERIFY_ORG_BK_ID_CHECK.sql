select count (*) as VERIFY_ORG_BK
    from fT_T_extr
    where ACCT_ORG_ID='EIS' and ACCT_BK_ID='EIS'
    and  trd_id='${TRD_ID}'
    And Instr_id in
                      (
                        select instr_id
                        from fT_T_isid
                        where iss_id='${Security_ID}'
                        and end_tms is null
                        and id_ctxt_typ in ('ISIN','SEDOL','CUSIP','${ID_CTXT_TYPE}')
                      )
    and  ACCT_ID IN
                       (
                         SELECT ACCT_ID
                         FROM FT_T_ACID
                         WHERE ACCT_ALT_ID='${FUND_ID}'
                         AND END_TMS IS NULL
                        )