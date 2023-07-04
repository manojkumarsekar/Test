#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=17.+Thomson+Reuters+Request+Reply
#As part of TOM-4636, New Requester Id BRSNPEOD has been added for requesting data from Reuters.

@gc_interface_reuters @gc_interface_npp @gc_interface_request_reply @002_request_reply_brseod
@dmp_regression_unittest
@tom_4636
Feature: 002 | NPP | BRS - DMP - TRDSS | Request reply feature to request for PositionsSource BRSNPEOD

  This testcase validate the Reuters Request and Reply for PositionsSource BRSNPEOD

  Below Steps are followed to validate this testing

  1. Generate the request file it should contain newly loaded positions
  2. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

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

    #This is to generate the request filename taking sequence value from previous step.
    And I execute below query and extract values of "REQUEST_FILE_NAME_1" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_1}' || '.xml' AS REQUEST_FILE_NAME_1
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'ReutersDSS_Terms_and_Conditions'
        """

    And I execute below query and extract values of "REQUEST_FILE_NAME_2" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_2}' || '.xml' AS REQUEST_FILE_NAME_2
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Reuters_Composite'
        """

    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME_1" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_1}' || '.csv' AS RESPONSE_FILE_NAME_1
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'ReutersDSS_Terms_and_Conditions'
        """

    And I execute below query and extract values of "RESPONSE_FILE_NAME_2" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_2}' || '.csv' AS RESPONSE_FILE_NAME_2
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Reuters_Composite'
        """

    # Clear VREQ
    And I execute below query
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND
	VND_RQST_XREF_ID_CTXT_TYP = 'SED' AND VND_RQST_XREF_ID IN ('BHJ0775','BZ8VJQ8')
	"""

    And I assign "tests/test-data/dmp-interfaces/NPP/BRS_EOD" to variable "testdata.path"
    And I assign "${dmp.ssh.inbound.path}/reuters" to variable "RT_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/reuters" to variable "RT_PATH_OUT"
    And I assign "${dmp.ssh.outbound.path}/reuters/done" to variable "RT_PATH_DONE"

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to RT for testing this is to simulate the process of request reply
    Given I copy files below from local folder "${testdata.path}/request/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_terms_conditions.xml |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_IN}":
      | gs_terms_conditions.csv |
    And I copy files below from local folder "${testdata.path}/request/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_composite.xml |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_IN}":
      | gs_composite.csv |

    Then I rename file "${RT_PATH_DONE}/gs_terms_conditions.xml" as "${RT_PATH_DONE}/${REQUEST_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_IN}/gs_terms_conditions.csv" as "${RT_PATH_IN}/${RESPONSE_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_DONE}/gs_composite.xml" as "${RT_PATH_DONE}/${REQUEST_FILE_NAME_2}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_IN}/gs_composite.csv" as "${RT_PATH_IN}/${RESPONSE_FILE_NAME_2}" in the named host "dmp.ssh.inbound"

    And I process ReutersDSSWrapper workflow with below parameters and wait for the job to be completed
      | FILTER_REQ       | Y              |
      | POSITIONS_SOURCE | BRSNPEOD       |
      | RT_DOWNLOAD_DIR  | ${RT_PATH_IN}  |
      | RT_UPLOAD_DIR    | ${RT_PATH_OUT} |
      | HST_REAS_TYP     | NPP            |

    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 4   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND   VND_RQST_XREF_ID_CTXT_TYP = 'SED' AND   VND_RQST_XREF_ID IN (
         'BHJ0775','BZ8VJQ8'
      )
     """