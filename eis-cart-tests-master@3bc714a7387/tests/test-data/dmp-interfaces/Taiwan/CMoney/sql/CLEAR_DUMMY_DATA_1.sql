    delete ft_T_mixr where isid_oid in (SELECT isid_oid FROM
        ft_t_isid where instr_id in (SELECT instr_id FROM
                                ft_t_issu
                            WHERE
                                pref_iss_id = 'TS3970000005'
                                AND   pref_iss_nme = 'TEST_3970'));

   delete ft_T_isid where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3970000005'
        AND   pref_iss_nme = 'TEST_3970');

   delete ft_T_mkis where instr_id in (SELECT instr_id FROM
           ft_t_issu
       WHERE
           pref_iss_id = 'TS3970000005'
           AND   pref_iss_nme = 'TEST_3970');

  delete ft_T_isde where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3970000005'
        AND   pref_iss_nme = 'TEST_3970');

  delete ft_T_iscl where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3970000005'
        AND   pref_iss_nme = 'TEST_3970');

  delete ft_T_ismc where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3970000005'
        AND   pref_iss_nme = 'TEST_3970');

  delete ft_T_issu where instr_id in (SELECT instr_id FROM
        ft_t_issu
    WHERE
        pref_iss_id = 'TS3970000005'
        AND   pref_iss_nme = 'TEST_3970');

  COMMIT;