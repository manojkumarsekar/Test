SELECT Count(1) AS RELOAD_INACTIVE_ROW_COUNT FROM  fT_t_isrt isrt where rtng_set_oid
in (SELECT rtng_set_oid FROM ft_t_rtng WHERE rtng_set_mnem = 'CARERT')
and Trunc(isrt.last_chg_tms) = Trunc(SYSDATE) AND isrt.end_tms is NOT null 
