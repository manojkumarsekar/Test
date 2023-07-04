---clean BALH entry for test security.
DELETE ft_t_bhst
WHERE  balh_oid IN (SELECT balh_oid
                    FROM   ft_t_balh
                    WHERE  instr_id IN (SELECT instr_id
                                        FROM   ft_t_isid
                                        WHERE  iss_id = 'S56810468'));

DELETE ft_t_balh
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id = 'S56810468');

---clean BREQUEST TABLES
DELETE FROM ft_t_vrpm
WHERE  vnd_rqst_oid IN (SELECT vnd_rqst_oid
                        FROM   ft_t_vreq
                        WHERE  vnd_rqst_xref_id IN (SELECT iss_id
                                                    FROM   ft_t_isid
                                                    WHERE
                               instr_id IN (SELECT instr_id
                                            FROM   ft_t_isid
                                            WHERE  iss_id = 'S56810468')));

DELETE FROM ft_t_vrpm
WHERE  vnd_rqst_oid in (select vnd_rqst_oid from ft_t_vreq
WHERE  prnt_vnd_rqst_oid IN (SELECT vnd_rqst_oid from ft_t_vreq
WHERE  vnd_rqst_xref_id IN (SELECT iss_id
                            FROM   ft_t_isid
                            WHERE  instr_id IN (SELECT instr_id
                                                FROM   ft_t_isid
                                                WHERE  iss_id = 'S56810468'))));

DELETE FROM ft_t_vreq
WHERE  vnd_rqst_oid in (select vnd_rqst_oid from ft_t_vreq
WHERE  prnt_vnd_rqst_oid IN (SELECT vnd_rqst_oid from ft_t_vreq
WHERE  vnd_rqst_xref_id IN (SELECT iss_id
                            FROM   ft_t_isid
                            WHERE  instr_id IN (SELECT instr_id
                                                FROM   ft_t_isid
                                                WHERE  iss_id = 'S56810468'))));

DELETE FROM ft_t_vrpm
WHERE  vnd_rqst_oid IN (SELECT vnd_rqst_oid from ft_t_vreq
WHERE  vnd_rqst_xref_id IN (SELECT iss_id
                            FROM   ft_t_isid
                            WHERE  instr_id IN (SELECT instr_id
                                                FROM   ft_t_isid
                                                WHERE  iss_id = 'S56810468')));

DELETE FROM ft_t_vreq
WHERE  vnd_rqst_oid IN (SELECT vnd_rqst_oid from ft_t_vreq
WHERE  vnd_rqst_xref_id IN (SELECT iss_id
                            FROM   ft_t_isid
                            WHERE  instr_id IN (SELECT instr_id
                                                FROM   ft_t_isid
                                                WHERE  iss_id = 'S56810468')));

DELETE FROM ft_t_isgu
WHERE  instr_id IN (SELECT instr_id
                    FROM   ft_t_isid
                    WHERE  iss_id IN ( 'TH062303O600', 'TH1074031804',
                                       'TH5435A34400',
                                       'TH0623A38308',
                                       'USY62526AB72', 'IE00B0M63623',
                                       'LU0514695690',
                                       'US4642865251',
                                       'TH0038037907', 'XS1728741346' ));

DELETE FROM ft_t_figu
WHERE  inst_mnem IN (SELECT inst_mnem
                     FROM   ft_t_frip
                     WHERE  instr_id IN (SELECT instr_id
                                         FROM   ft_t_isid
                                         WHERE  iss_id IN ( 'TH062303O600',
                                                            'TH1074031804',
                                                            'TH5435A34400',
                                                            'TH0623A38308',
                                                            'USY62526AB72',
                                                            'IE00B0M63623',
                                                            'LU0514695690',
                                                            'US4642865251',
                                                            'TH0038037907',
                                                            'XS1728741346' )));

COMMIT;