	 SELECT COUNT(*) AS VERIFY_ISCL_ESJP
	  FROM FT_T_ISCL
	  WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID='2113382' AND ID_CTXT_TYP = 'ESJPCODE' AND END_TMS IS NULL)
	  and CL_VALUE ='COM'
	  and INDUS_CL_SET_ID='ESJPSECTYP'
	  and CLSF_PURP_TYP='ESJPSECTYP'