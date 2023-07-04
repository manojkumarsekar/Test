#https://collaborate.intranet.asia/display/TOMID/INDONESIA+Consolidated+Requirements#businessRequirements-508441805
#https://jira.intranet.asia/browse/TOM-3560
#https://jira.intranet.asia/browse/TOM-4090 : Updated inbound outbound path location

@gc_interface_positions @gc_interface_securities @gc_interface_request_reply
@dmp_regression_integrationtest
@tom_3560 @id_cdf_inbound @tom_4090 @dmp_gs_upgrade
Feature: Request reply feature of CDF requirements to download PREV_CPN_DT, NXT_CPN_DT & DAYS_ACC from BB

  3 CDF fields to be sourced from Bloomberg and published to BRS for all FI holdings.
  This testcase validate the BB Request and Reply.

  Below Steps are followed to validate this testing

  1. Load the positions(i.e 10 rows) for NDSFIA, NDCRMF funds having INCL = RDMSCTYP as CB, GB, QGB, COM & LOAN using the "EIS_MT_BRS_EOD_POSITION_LATAM" Messagetype
  2. Generate the request file it should contains newly loaded positions Plus other rows
  3. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3560" to variable "testdata.path"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/positions"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |
    When I copy files below from local folder "${testdata.path}/positions/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |

     #This check to verify BALH table MAX(AS_OF_TMS) rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "10":
     """
     SELECT COUNT(0) AS BALH_COUNT
     FROM   FT_T_BALH BALH, FT_T_ISID ISID
     WHERE  BALH.INSTR_ID = ISID.INSTR_ID
     AND    ISID.ID_CTXT_TYP = 'BCUSIP'
     AND    ISID.ISS_ID IN ('BPM0NPVU9','BPM1A90S6','BPM10ZQQ5','S62248711','BPM16YG00','BPM0QY6S0','BPM0MNAW4','BPM08HMG5','S62505425','BRTDDMM87')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     AND    BALH.RQSTR_ID = 'BRSEOD'
     AND    BALH.AS_OF_TMS IN (SELECT  MAX(AS_OF_TMS) FROM FT_T_BALH WHERE RQSTR_ID = 'BRSEOD')
     """

  Scenario: TC_2: Check the BB Request Reply

    # Assign Variables
    Given I assign "/dmp/out/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/in/bloomberg" to variable "BB_UPLOAD_DIR"

    #This is to generate the response filename which is driven by database sequence
    Given I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """

    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """

    And I execute below query to "Duplicate FINS got created for KAZMUNAYGAS NATIONAL CO JSC. This is to end-date one of them."
	"""
	UPDATE FT_T_FINS SET END_TMS = SYSDATE WHERE INST_NME = 'KAZMUNAYGAS NATIONAL CO JSC' AND ROWNUM=1
	AND 2 = (SELECT COUNT(1) FROM FT_T_FINS WHERE INST_NME = 'KAZMUNAYGAS NATIONAL CO JSC' AND END_TMS IS NULL)
	"""

    #ISCL for BBMKTSCT is not setup for below ISIN's so the request goes to BB without Market Sector in it. Since, BBMKTSCT is setup through BB loads.
    #BBMKTST will be created in this load itself and if we run this process again it will generate request with Market Sector in it.
    #This step is to clear BBMKTSCT so that request file is generated without BBMKTSCT.
    And I execute below query to "clear BBMKTSCT so that request file is generated without BBMKTSCT."
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('MYBVN1703757','XS1595714087') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'BBMKTSCT' AND CLSF_PURP_TYP = 'INDCLASS' AND END_TMS IS NULL
	"""

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to ICE for testing this is to simulate the process of request reply
    Given I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | gs_secmaster_response_template.out |

    Then I rename file "${BB_DOWNLOAD_DIR}/gs_secmaster_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Secmaster      |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

     #This check to verify if only 6 securities which satisfied condition of RDMSCTYP were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) >= 6   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Secmaster' AND   VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND   VND_RQST_XREF_ID IN (
          'XS1595714087', 'ARARGE3205N5', 'MYBVN1703757', 'INE001A07QM8', 'SG31B5000004', 'INE020B08864', 'KR7017670001', 'JP3485800001'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND   VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

    #This is to verify if ISST were created
    Then I expect value of column "ISST_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 15   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS ISST_CHECK
      FROM FT_T_ISST
      WHERE STAT_DEF_ID IN (
          'NXTCPNDT', 'PRECPNDT', 'DAYSACC'
      ) AND   INSTR_ID IN ( SELECT INSTR_ID
                          FROM FT_T_ISID
                          WHERE ISS_ID IN (
          'XS1595714087', 'ARARGE3205N5', 'MYBVN1703757', 'INE001A07QM8', 'SG31B5000004', 'INE020B08864'
      )
      )
     """

    #This is to verify if BDST were created with PREV_CPN_DT & NXT_CPN_DT populated
    Then I expect value of column "BDST_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 5   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS BDST_CHECK
      FROM FT_T_BDST
      WHERE PREV_CPN_DTE IS NOT NULL AND   NXT_CPN_DTE IS NOT NULL AND   INSTR_ID IN ( SELECT INSTR_ID
                                                                                   FROM FT_T_ISID
                                                                                   WHERE ISS_ID IN (
          'XS1595714087', 'ARARGE3205N5', 'MYBVN1703757', 'INE001A07QM8', 'SG31B5000004', 'INE020B08864'
      )
      )
     """

