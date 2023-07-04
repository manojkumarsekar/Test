#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=17.+Thomson+Reuters+Request+Reply
#As part of TOM-4636, New Requester Id BNPNPSOD has been added for requesting data from Reuters.
#https://jira.pruconnect.net/browse/EISDEV-6402
#Copied request files to done directory as Timeout is increased as aprt of EISDEV-6402

@gc_interface_reuters @gc_interface_npp @gc_interface_request_reply @004_request_reply_bnpsod
@dmp_regression_unittest @eisdev_6843
@tom_4636 @eisdev_6402
Feature: 004 | NPP | BNP - DMP - TRDSS | Request reply feature to request for PositionsSource BNPNPSOD

  This testcase validate the Reuters Request and Reply for PositionsSource BNPNPSOD

  Below Steps are followed to validate this testing

  1. Generate the request file it should contain newly loaded positions
  2. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

  Scenario: Assign Variables and Create Input Files with T-1 Data

    Given I assign "tests/test-data/dmp-interfaces/NPP/BNP_SOD" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "004_ESISODP_SDP_Position.out" to variable "INPUTFILE_NAME"
    And I assign "${dmp.ssh.inbound.path}/reuters" to variable "RT_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/reuters" to variable "RT_PATH_OUT"
    And I assign "${dmp.ssh.outbound.path}/reuters/done" to variable "RT_PATH_DONE"
    And I execute below query and extract values of "T_1_YYYYMONDD" into same variables
     """
     select TO_CHAR(sysdate-1, 'YYYY-MON-DD') AS T_1_YYYYMONDD from dual
     """
    And I create input file "${INPUTFILE_NAME}" using template "004_ESISODP_SDP_Position_Template.out" from location "${testdata.path}/inputfiles"

    # As part of regression, other feature file are loading T date position but here T-1 date.
    Given I execute below query to "Delete BALH for RQSTR_ID BNPNPSOD"
	"""
    DELETE FT_T_BHST WHERE BALH_OID IN (SELECT BALH_OID FROM FT_T_BALH WHERE AS_OF_TMS >= trunc(SYSDATE) -1 and RQSTR_ID = 'BNPNPSOD');
    DELETE FT_T_BALH WHERE AS_OF_TMS >= trunc(SYSDATE)-1 and RQSTR_ID = 'BNPNPSOD';
    COMMIT
	"""

  Scenario: Load BNP SDP position File

    And I process "${testdata.path}/inputfiles/testdata/${INPUTFILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME}                     |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |
      | BUSINESS_FEED |                                       |

    Then I expect workflow is processed in DMP with total record count as "4"

    #This check to verify BALH table MAX(AS_OF_TMS) rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "4":
     """
     SELECT COUNT(0) AS BALH_COUNT
     FROM   FT_T_BALH BALH, FT_T_ISID ISID
     WHERE  BALH.INSTR_ID = ISID.INSTR_ID
     AND    ISID.ID_CTXT_TYP = 'SEDOL'
     AND    ISID.ISS_ID IN ('B1530B1','6858902','6597603','B00Q6Z4')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     AND    BALH.RQSTR_ID = 'BNPNPSOD'
     AND    BALH.AS_OF_TMS IN (SELECT  MAX(AS_OF_TMS) FROM FT_T_BALH WHERE RQSTR_ID = 'BNPNPSOD')
     """

  Scenario: Check Reuters Request Reply for ReutersDSS_Terms_and_Conditions

    #This is to generate the response filename which is driven by database sequence
    Given I execute below query and extract values of "SEQ_1" into same variables
      """
      SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ_1 FROM DUAL
      """

    And I execute below query and extract values of "SEQ_2" into same variables
      """
      SELECT LPAD(${SEQ_1}+1,8,'0') AS SEQ_2 FROM DUAL
      """

    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME_1;REQUEST_FILE_NAME_1" into same variables
      """
      SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_1}' || '.csv' AS RESPONSE_FILE_NAME_1,
      SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_1}' || '.xml' AS REQUEST_FILE_NAME_1
      FROM FT_CFG_VRTY
      WHERE VND_RQST_TYP = 'ReutersDSS_Terms_and_Conditions'
      """

    And I execute below query and extract values of "RESPONSE_FILE_NAME_2;REQUEST_FILE_NAME_2" into same variables
      """
      SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_2}' || '.csv' AS RESPONSE_FILE_NAME_2,
      SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_2}' || '.xml' AS REQUEST_FILE_NAME_2
      FROM FT_CFG_VRTY
      WHERE VND_RQST_TYP = 'EIS_Reuters_Composite'
      """

    And I execute below query to "Clear VREQ"
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND
	VND_RQST_XREF_ID_CTXT_TYP = 'SED' AND VND_RQST_XREF_ID IN ('B1530B1','6858902','6597603','B00Q6Z4')
	"""

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to RT for testing this is to simulate the process of request reply
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_IN}":
      | gs_terms_conditions.csv |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_IN}":
      | gs_composite.csv |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_terms_conditions.csv |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_composite.csv |

    And I rename file "${RT_PATH_IN}/gs_terms_conditions.csv" as "${RT_PATH_IN}/${RESPONSE_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_IN}/gs_composite.csv" as "${RT_PATH_IN}/${RESPONSE_FILE_NAME_2}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_DONE}/gs_terms_conditions.csv" as "${RT_PATH_DONE}/${REQUEST_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_DONE}/gs_composite.csv" as "${RT_PATH_DONE}/${REQUEST_FILE_NAME_2}" in the named host "dmp.ssh.inbound"

    And I process ReutersDSSWrapper workflow with below parameters and wait for the job to be completed
      | FILTER_REQ       | Y              |
      | POSITIONS_SOURCE | BNPNPSOD       |
      | RT_DOWNLOAD_DIR  | ${RT_PATH_IN}  |
      | RT_UPLOAD_DIR    | ${RT_PATH_OUT} |

    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 8   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND   VND_RQST_XREF_ID_CTXT_TYP = 'SED'
      AND   VND_RQST_XREF_ID IN ('B1530B1','6858902','6597603','B00Q6Z4')
     """