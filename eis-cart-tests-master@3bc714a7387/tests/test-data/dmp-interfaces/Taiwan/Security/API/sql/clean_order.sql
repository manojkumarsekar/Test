UPDATE ft_t_auor
SET    pref_order_id = new_oid,
       last_chg_usr_id = last_chg_usr_id
                         || 'AUTOMATION',
       last_chg_tms = sysdate
WHERE  pref_order_id = '${ORD_NUM}'
       AND pref_order_id_ctxt_typ = 'BRS_ORDER';

COMMIT;