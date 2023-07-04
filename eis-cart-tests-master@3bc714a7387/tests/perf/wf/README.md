# How to run

Connect to the database of the environment, and find a valid job id:

	SELECT JOB_ID FROM GS_GC.FT_T_JBLG WHERE ROWNUM = 1;

Put the result into the field in the SOAP Request.