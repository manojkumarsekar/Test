#https://collaborate.intranet.asia/pages/viewpage.action?pageId=42009388
#https://jira.intranet.asia/browse/TOM-3334
#https://jira.intranet.asia/browse/TOM-3621 - As part of this ticket MAX(AS_OF_TMS) removed because business user needs the historical data

@gc_interface_ice @gc_interface_refresh_soi @gc_interface_positions @gc_interface_request_reply
@dmp_regression_integrationtest
@tom_3334 @tom_3621 @dmp_ice_workflow
Feature: Testing EIS_ICEPerSecurity Workflow

  This testcase validate the ICE Request and Reply Workflow

  Below Steps are followed to validate this testing

  1. Load the positions(i.e 10 rows) for Malaysia using the "EIS_MT_BRS_EOD_POSITION_LATAM" Messagetype
  2. Call the Refresh SOI for BPAM
  3. Validate the ISGP Active and Inactive status
  4. Generate the request file it should contains newly loaded positions Plus other rows
  5. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3334" to variable "testdata.path"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/positions"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    When I copy files below from local folder "${testdata.path}/positions/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |


     #This check to verify BALH table rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "10":
     """
     SELECT count(distinct ISID.ISS_ID) AS BALH_COUNT
     FROM   FT_T_BALH BALH, FT_T_ISID ISID
     WHERE  BALH.INSTR_ID = ISID.INSTR_ID
     AND    ISID.ISS_ID LIKE 'MY%'
     AND    ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     AND    BALH.RQSTR_ID = 'BRSEOD'
     """

  Scenario: TC_2: Check the EIS_RefreshSOI workflow, it will refresh SOI for BPAM

    Given I execute below query
	"""
	DELETE FROM FT_T_ISGP WHERE PRNT_ISS_GRP_OID = 'BPAMPSRSOI' AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID = 'JP1300511G61' AND END_TMS IS NULL);
	INSERT INTO FT_T_ISGP (SELECT 'BPAMPSRSOI',SYSDATE,NULL,INSTR_ID,SYSDATE,'EIS:CSTM','MEMBER',NULL,NULL,NULL,NULL,'ACTIVE','ICE APEX',NULL,NULL,NULL,NULL,NEW_OID,NULL
    FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
	"""

    #This will refresh SOI for BPAMP
    When I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | BPAMPSRSOI               |
      | NO_OF_BRANCH | 5                        |
      | QUERY_NAME   | EIS_REFRESH_BPAM_PSR_SOI |

    #This check to verify SOI table(ISGP) rows are UPDATED/Inserted
    Then I expect value of column "ISGP_COUNT" in the below SQL query equals to "1":
     """
     SELECT CASE WHEN COUNT(0)>=10 THEN 1 ELSE 0 END AS ISGP_COUNT FROM FT_T_ISGP where prnt_iss_grp_oid='BPAMPSRSOI' and instr_id in (
     SELECT INSTR_ID FROM FT_T_ISID  ISID
     WHERE  ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL)
     """

    #This check to verify Inactive Rows in ISGP(i.e SOI Participants table)
    Then I expect value of column "ACTIVE_STATUS" in the below SQL query equals to "INACTIVE":
     """
     SELECT data_stat_typ as ACTIVE_STATUS FROM FT_T_ISGP  where prnt_iss_grp_oid='BPAMPSRSOI' and instr_id IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
     """

    #This check to verify active Rows in ISGP(i.e SOI Participants table)
    Then I expect value of column "ACTIVE_STATUS" in the below SQL query equals to "ACTIVE":
     """
     SELECT distinct data_stat_typ as ACTIVE_STATUS FROM FT_T_ISGP  where prnt_iss_grp_oid='BPAMPSRSOI' and instr_id in (
     SELECT INSTR_ID FROM FT_T_ISID  ISID
     WHERE  ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL)
     """

  Scenario: TC_3: Check the ICE Request and Reply

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "ICEBPAM_ESI_PRICE_REF_TEMPLATE.csv" to variable "RESPONSE_INPUT_TEMPLATENAME"
    And I assign "ESI_ICEBPAM_REQUEST_${VAR_SYSDATE}.csv" to variable "request.file"
    And I assign "ICEBPAM_ESI_PRICE_REF.csv" to variable "response.file"

    And I create input file "${response.file}" using template "${RESPONSE_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/response"
      | POS_DATE | DateTimeFormat:YYYYMMdd |

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to ICE for testing this is to simulate the process of request reply
    Given I copy files below from local folder "${testdata.path}/response/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.outbound.path}":
      | ${response.file} |

    Then I rename file "${dmp.ssh.outbound.path}/${response.file}" as "${dmp.ssh.outbound.path}/ICEBPAM_ESI_PRICE_REF_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    Given I process ICEPerSecurity workflow with below parameters and wait for the job to be completed
      | ICE_DOWNLOAD_DIRECTORY          | ${dmp.ssh.outbound.path} |
      | ICE_TIMEOUT                     | 300                      |
      | ICE_UPLOAD_DIRECTORY            | ${dmp.ssh.inbound.path}  |
      | MAX_REQUESTS_PER_FILE           | 100000                   |
      | PRICE_POINT_EVENT_DEFINITION_ID | ESIPRPTEOD               |
      | REQUEST_TYPE                    | EIM_ICERefdata           |
      | REQUESTOR_ID                    | EIM                      |

     #This check to verify Price table(ISPC) rows are inserted
    Then I expect value of column "PRICE_CODE_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
     SELECT CASE WHEN COUNT(0)>=10 THEN 'PASS' ELSE 'FAIL' END AS PRICE_CODE_STATUS_CHECK FROM FT_T_ISPC WHERE LAST_CHG_USR_ID='EIM_ICE_DMP_REFDATA' AND TRUNC(ADJST_TMS)=TRUNC(SYSDATE) AND INSTR_ID IN (
     SELECT INSTR_ID FROM FT_T_ISID  ISID
     WHERE  ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     )
     """

    #This check to verify VREQ is closed
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
     SELECT CASE WHEN COUNT(1)>=10 THEN 'PASS' ELSE 'FAIL' END AS VREQ_STATUS_CHECK FROM FT_T_VREQ WHERE TRUNC(VND_RQST_TMS) = TRUNC(SYSDATE)
     AND VND_RQST_TYP = 'EIM_ICERefdata' AND VND_RQST_XREF_ID_CTXT_TYP = 'EISLSTID' AND VND_RQST_XREF_ID IN
    ('ESL1872842','ESL1927168','ESL4802177','ESL4825282','ESL4825284','ESL5684629','ESL6562175','ESL7182943','ESL7222618','ESL8348812','ESL8616191','ESL8960093') AND VND_RQST_STAT_TYP = 'CLOSED'
     """



