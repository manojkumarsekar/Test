#https://collaborate.intranet.asia/pages/viewpage.action?pageId=42009388
#https://jira.intranet.asia/browse/TOM-3579
#https://jira.intranet.asia/browse/TOM-3582
#TOM-3621:Request file generation from DMP to ICEBPAM should be based on the positions held by MY portfolio's (current and historical positions), and ISIN's code starting with MY
# https://jira.intranet.asia/browse/TOM-4780: Adding saveDetails and closeTab steps for Industry Classification

@gc_interface_positions @gc_interface_refresh_soi
@dmp_regression_integrationtest
@tom_3579 @gs_ui_industry_classification @eisdev_7481
Feature: New Security group rule for BPAM Request file(i.e TOM-3579), Removing Match key CFTISetMatchKey(i.e TOM-3582)

  These testcase are validate the ICE Request file contains BRS Security group (i.e BND and ABS) and ISIN code starting with MY.

  Below Steps are following to validate this testing

  PreRequest
  1. Load the positions (i.e Total 12 rows, 10 for BND and 2 for Equity) for Malaysia using the "EIS_MT_BRS_EOD_POSITION_LATAM" Messagetype
  2. Call the Refresh SOI for BPAM

  Testcase
  3. Check FT_T_ISGP table contains the BRS Security group (i.e BND and ABS) with an ISIN code starting with MY instrument id only. Filter condition for this table is prnt_iss_grp_oid='BPAMPSRSOI'
  4. Create the New BRS SecGroup via GS UI which should insert row into FT_T_CCRF and FT_T_INCL, this will cover TOM-3582 testcase
  5. Add the Newly created BRS Secgroup into Participants table (i.e ft_t_crgp)

  Scenario: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3579" to variable "testdata.path"

    And I execute below query to "Delete any entity in Pending Approval state"

    """
    DELETE FROM FT_WF_UIWA
    WHERE MAIN_ENTITY_ID = 'SECGROUP'
    AND USER_INSTRUC_TXT IS NULL;
    COMMIT;
    """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/positions"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    When I copy files below from local folder "${testdata.path}/positions/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |

   #This check to verify BALH table MAX(AS_OF_TMS) rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "12":
     """
     SELECT COUNT(distinct ISID.ISS_ID) AS BALH_COUNT
     FROM   FT_T_BALH BALH, FT_T_ISID ISID
     WHERE  BALH.INSTR_ID = ISID.INSTR_ID
     AND    ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767','MYL1015OO006','MYL1023OO000')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     AND    BALH.RQSTR_ID = 'BRSEOD'
     """

  Scenario: Check the EIS_RefreshSOI workflow, it will refresh SOI for BPAM

    Given I execute below query
	"""
	DELETE FROM FT_T_ISGP WHERE PRNT_ISS_GRP_OID = 'BPAMPSRSOI' AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
	"""

    And I execute below query
	"""
	INSERT INTO FT_T_ISGP
    (SELECT 'BPAMPSRSOI',SYSDATE,NULL,INSTR_ID,SYSDATE,'EIS:CSTM','MEMBER',NULL,NULL,NULL,NULL,'ACTIVE','ICE APEX',NULL,NULL,NULL,NULL,NEW_OID,NULL
    FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
	"""

    #This will refresh SOI for BPAMP
    When I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | BPAMPSRSOI               |
      | NO_OF_BRANCH | 5                        |
      | QUERY_NAME   | EIS_REFRESH_BPAM_PSR_SOI |

    #This check to verify Inactive Rows in FT_T_ISGP table for Japan ISIN(i.e SOI Participants table)
    Then I expect value of column "ACTIVE_STATUS" in the below SQL query equals to "INACTIVE":
     """
     SELECT data_stat_typ as ACTIVE_STATUS FROM FT_T_ISGP  where prnt_iss_grp_oid='BPAMPSRSOI' and instr_id in (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
     """

    #Check FT_T_ISGP table(i.e SOI Participants table) contains BND and ABS secgroup with an ISIN code starting with MY instrument id only. Filter condition for this table is prnt_iss_grp_oid='BPAMPSRSOI'
    Then I expect value of column "ISGP_COUNT" in the below SQL query equals to "1":
     """
     SELECT CASE WHEN COUNT(0)=10 THEN 1 ELSE 0 END AS ISGP_COUNT FROM FT_T_ISGP where prnt_iss_grp_oid='BPAMPSRSOI' and data_stat_typ='ACTIVE' and instr_id in (
     SELECT INSTR_ID FROM FT_T_ISID  ISID
     WHERE  ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767','MYL1015OO006','MYL1023OO000')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL)
     """

  # Check FT_T_ISGP table(i.e SOI Participants table) does not contains other then BND and ABS with an ISIN code starting with MY instrument id . Filter condition for this table is prnt_iss_grp_oid='BPAMPSRSOI'
  # the below iss_id from Equity secgroup and this query should return 0
    Then I expect value of column "ISGP_COUNT" in the below SQL query equals to "0":
     """
     SELECT CASE WHEN COUNT(0)=0 THEN 0 ELSE 1 END AS ISGP_COUNT FROM FT_T_ISGP where prnt_iss_grp_oid='BPAMPSRSOI' and data_stat_typ='ACTIVE' and instr_id in (
     SELECT INSTR_ID FROM FT_T_ISID  ISID
     WHERE  ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYL1015OO006','MYL1023OO000')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL)
     """

  @web
  Scenario: Create  Industry Classification Set with SECGROUP
    Given I login to golden source UI with "task_assignee" role
    And I assign "Test_BRS_SECGROUP" to variable "INPUT_CLVALUE"
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    When I add Industry Classification Details for Classification set "SECGROUP" with following details
      | Class Name                     | ${INPUT_CLVALUE}              |
      | Class Description              | ${INPUT_CLVALUE}              |
      | Classification Value           | ${INPUT_CLVALUE}${VAR_RANDOM} |
      | Level Number                   | 1                             |
      | Classification Created On      | T                             |
      | Classification Effective Until |                               |

    And I save the valid data
    And I close active GS tab

    Then I expect a record in My WorkList with entity id "SECGROUP" and status "Open"
    And I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "SECGROUP"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Industry Classification Details for set "SECGROUP" are updated as below
      | Class Name           | ${INPUT_CLVALUE}              |
      | Class Description    | ${INPUT_CLVALUE}              |
      | Classification Value | ${INPUT_CLVALUE}${VAR_RANDOM} |

    And I close active GS tab

    Then I expect value of column "CCRF_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) AS CCRF_COUNT FROM FT_T_CCRF
    WHERE CL_VALUE = '${INPUT_CLVALUE}${VAR_RANDOM}'
    AND END_TMS IS NULL
    AND CLSF_OID = (SELECT CLSF_OID
    FROM FT_T_INCL
    WHERE CL_NME = '${INPUT_CLVALUE}'
    AND CL_VALUE = '${INPUT_CLVALUE}${VAR_RANDOM}'
    AND TRIM(INDUS_CL_SET_ID) = 'SECGROUP'
    AND END_TMS IS NULL)
    """

  @3579_Validate_Participants
  Scenario: Add the Newly created BRS Secgroup into Participants table (i.e ft_t_crgp)
    Given I execute below query
	"""
	INSERT INTO FT_T_CRGP
    (PRNT_CRGR_OID , START_TMS ,CNTL_CROSS_REF_OID,CROSS_REF_GRP_OID,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,PRT_PURP_TYP,PRT_DESC,DATA_STAT_TYP,DATA_SRC_ID,CRGP_OID,PART_CAMT,PART_CURR_CDE,PART_CPCT)
     SELECT 'CRREQREP07' , SYSDATE , CNTL_CROSS_REF_OID , NULL, NULL,SYSDATE,'EIS:CSTM','MEMBER', NULL ,NULL,'ICE APEX' ,NEW_OID , NULL ,NULL ,NULL FROM FT_T_CCRF CCRF
     WHERE CROSS_REF_PURP_TYP = 'INCL' AND CL_VALUE IN ('${INPUT_CLVALUE}${VAR_RANDOM}') AND END_TMS IS NULL  AND NOT EXISTS (SELECT 1
                        FROM   FT_T_CRGP
                        WHERE  PRNT_CRGR_OID = 'CRREQREP07'
                             AND CNTL_CROSS_REF_OID = CCRF.CNTL_CROSS_REF_OID
                             AND DATA_SRC_ID = 'ICE APEX'
                             AND END_TMS IS NULL)

     """
    # The below steps help to validate, system able to insert the rows in the participants table.
    Then I expect value of column "CRGP_COUNT" in the below SQL query equals to "1":
        """
        SELECT CASE WHEN COUNT(0)>=1 THEN 1 ELSE 0 END as CRGP_COUNT FROM FT_T_CRGP WHERE PRNT_CRGR_OID='CRREQREP07' AND  DATA_SRC_ID='ICE APEX'
       AND CNTL_CROSS_REF_OID IN (SELECT CNTL_CROSS_REF_OID FROM FT_T_CCRF WHERE  CROSS_REF_PURP_TYP = 'INCL' AND CL_VALUE IN ('${INPUT_CLVALUE}${VAR_RANDOM}') AND END_TMS IS NULL)
         """
