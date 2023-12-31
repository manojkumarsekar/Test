SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS CL_VALUE_CHECK FROM FT_T_ISCL WHERE CL_VALUE = '${VAR_ASSET_TYPE}' AND INDUS_CL_SET_ID='BNPASTYP' AND END_TMS IS NULL AND
INSTR_ID = (
                SELECT INSTR_ID FROM FT_T_ISID
                WHERE ID_CTXT_TYP='BNPLSTID'
                AND ISS_ID='${VAR_INSTR_ID}'
                AND END_TMS IS NULL
            )
