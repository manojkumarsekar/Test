# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 25/03/2019      TOM-4396    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4396
#https://collaborate.intranet.asia/display/FUNDAPPS
#Funds RCRLBU file

@tom_4396 @fund_apps @fund_apps_Fund @tom_4633

Feature: TOM_4396 SSDR_INBOUND | Fund


  Scenario: TC_1: Creat Insert for SSH FLAG  attributes stored in DMP Fund File

    Then I expect value of column "VERIFY_SSHFLAG" in the below SQL query equals to "1":
    """
	select count(*)as VERIFY_SSHFLAG
	from fT_T_stdf
	where STAT_DEF_ID ='SSHFLAG'
	"""

  Scenario: TC_2: Insert SSHFLAG is Y for Extract of fund File for where Account name And Acoount Id is compare &  insert flag "Y" for  those

    Then I expect value of column "VERIFY_INSERT_DATA" in the below SQL query equals to "525":
    """
	SELECT COUNT(*) AS VERIFY_INSERT_DATA
	FROM FT_T_ACST
    where STAT_DEF_ID='SSHFLAG'
    AND STAT_CHAR_VAL_TXT='Y'
    AND LAST_CHG_USR_ID = 'EIS:CSTM'
    AND END_TMS IS NULL
    """