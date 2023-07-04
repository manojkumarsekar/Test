with TBL1 as
(
    select ISS_ID from FT_T_ISID
    where INSTR_ID in
    (
        select INSTR_ID from FT_T_ISID where ISS_ID='${RCR_ISIN}' and END_TMS is null
    )
    and ID_CTXT_TYP='EISLSTID'
    and END_TMS is null
),
TBL2 as
(
    select ISS_NME from FT_T_ISDE
    where INSTR_ID in
    (
        select INSTR_ID from FT_T_ISID where ISS_ID='${RCR_ISIN}' and END_TMS is null
    )
    and END_TMS is null
    and DESC_USAGE_TYP='PRIMARY'
) select TBL1.ISS_ID, TBL2.ISS_NME from TBL1 cross join TBL2
