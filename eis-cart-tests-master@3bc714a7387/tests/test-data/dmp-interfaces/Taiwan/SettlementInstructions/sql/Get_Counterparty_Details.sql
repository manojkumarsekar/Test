 SELECT COUNTERPARTY_NAME AS COUNTERPARTY_NAME${RN}, TRD_COUNTERPARTY AS TRD_COUNTERPARTY${RN}
     from (SELECT fide.INST_NME AS COUNTERPARTY_NAME, fiid.FINS_ID AS TRD_COUNTERPARTY, ROWNUM AS rn FROM FT_T_FIDE fide
     inner join FT_T_FIID fiid
     on fide.INST_MNEM=fiid.INST_MNEM
     where fiid.FINS_ID like '%TW'
     and fiid.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
     AND fiid.end_tms IS NULL
     )
     WHERE rn =${RN}