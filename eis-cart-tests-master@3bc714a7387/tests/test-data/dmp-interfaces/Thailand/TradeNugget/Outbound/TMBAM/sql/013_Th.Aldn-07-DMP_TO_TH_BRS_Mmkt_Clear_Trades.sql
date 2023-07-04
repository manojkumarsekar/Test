UPDATE
          FT_T_EXTR
      SET
          TRD_ID = NEW_OID,
          end_tms = sysdate
      where
          TRD_ID in (
              '16039-100001',
              '16039-100002'
          );