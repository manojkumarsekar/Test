  delete ft_T_isid where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3680000006'
        AND   pref_iss_nme = 'TEST_3680');

  delete ft_T_isde where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3680000006'
        AND   pref_iss_nme = 'TEST_3680');

  delete ft_T_iscl where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3680000006'
        AND   pref_iss_nme = 'TEST_3680');

  delete ft_T_ismc where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3680000006'
        AND   pref_iss_nme = 'TEST_3680');

  delete ft_T_issu where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3680000006'
        AND   pref_iss_nme = 'TEST_3680');

  COMMIT;
  delete ft_T_isid where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TE3680000002'
        AND   pref_iss_nme = 'TEST3680_1');

  delete ft_T_isde where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TE3680000002'
        AND   pref_iss_nme = 'TEST3680_1');

  delete ft_T_iscl where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TE3680000002'
        AND   pref_iss_nme = 'TEST3680_1');


  delete ft_T_frip where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TE3680000002'
        AND   pref_iss_nme = 'TEST3680_1');

  delete ft_T_issu where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TE3680000002'
        AND   pref_iss_nme = 'TEST3680_1');

 delete from ft_T_frip where inst_mnem in (select inst_mnem from ft_T_fins where inst_nme ='TEST3680');
  delete from ft_T_finr where inst_mnem in (select inst_mnem from ft_T_fins where inst_nme ='TEST3680');
  delete from ft_T_fiid where inst_mnem in (select inst_mnem from ft_T_fins where inst_nme ='TEST3680');
  delete ft_T_fide where inst_mnem in (select inst_mnem from ft_T_fins where inst_nme ='TEST3680');
  delete ft_T_fins where inst_nme ='TEST3680';
  COMMIT;