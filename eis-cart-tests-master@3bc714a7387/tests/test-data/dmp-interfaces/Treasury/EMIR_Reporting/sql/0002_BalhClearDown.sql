DELETE FT_T_BALH
WHERE RQSTR_ID='${RQSTR_ID}'
and trunc(LAST_CHG_TMS)= trunc(sysdate)
and trunc(as_of_tms) = '16-SEP-2019';

COMMIT;