	 SELECT COUNT(*) AS VERIFY_ISCL_BOCI
	  FROM FT_T_ISCL
	  WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID='6073556' AND END_TMS IS NULL)
	  and CL_VALUE ='COM'
	  and INDUS_CL_SET_ID='BOCISCTYPE'
	  and CLSF_PURP_TYP='BOCISCTYPE'