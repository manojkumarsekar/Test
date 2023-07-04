SELECT Sum(prc1_unit_cprc)  UNIT_CPRC
FROM   ft_v_prc1
WHERE  prc1_eislstid IN ( 'ESL7706444',
                         'ESL8950744',
                         'ESL6497473',
                         'ESL3721369',
                         'ESL9609262' )
AND    prc1_prc_tms = Trunc(Last_day(Add_months(sysdate, -1)) - Decode( To_char(Last_day( Add_months(sysdate, -1) ), 'd'), '7', 1, '1' , 2, 0)) 
AND    prc1_prc_typ = 'SODEIS'
AND    prc1_prcng_meth_typ = 'ESIPX'
AND    prc1_prc_srce_typ= 'ESM'
AND    prc1_grp_nme= 'STLPRCSOI'