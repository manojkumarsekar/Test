#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=17.+Thomson+Reuters+Request+Reply
#https://jira.intranet.asia/browse/TOM-3374

#TOM-4347 - Implement Request Reply for Reuters
#EISDEV_6444: Update fetch_portfolio_code.sql to fetch portfolios with ACCT_ALT_ID in Upper case only. This is because the BRS positions MDX has below lookup condition to fetch portfolio
#return UpperCase(POSITIONS.POSITION.PORTFOLIOS_PORTFOLIO_NAME);
#EISDEV-6318: Duplicate VREQs generated for multilisted securities fix. As a result, the count of expected VREQs reduces
#https://jira.pruconnect.net/browse/EISDEV-6402
#Copied request files to done directory as Timeout is increased as aprt of EISDEV-6402

#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@gc_interface_positions @gc_interface_reuters @gc_interface_request_reply

#@dmp_regression_integrationtest
@dmp_regression_unittest
@tom_4347 @tom_4347_1002 @dmp_fundapps_regression @request_reply_reuters @tom_4432 @tom_4458 @tom_4561 @eisdev_6444 @eisdev_6318 @eisdev_6402
Feature: Request reply feature to request securities from Reuters based on positions of the PositionsSource passed to the workflow for NonLatam.

  This testcase validate the Reuters Request and Reply.

  Below Steps are followed to validate this testing

  1. Load positions for 2 portfolios using BRS loader
  2. Generate the request file it should contain newly loaded positions Plus other rows if any
  3. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_template_nonlatam.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Reuters" to variable "testdata.path"

    And I execute below query and extract values of "PORTFOLIO_CRTS_1;PORTFOLIO_CRTS_2" into same variables
     """
     ${testdata.path}/sql/fetch_portfolio_codes.sql
     """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/position"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    And I copy files below from local folder "${testdata.path}/position/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query
     """
     ${testdata.path}/sql/clean_future_dated_balh.sql
     """

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |

     #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "4":
     """
     ${testdata.path}/sql/check_positions_loaded.sql
     """

  Scenario: TC_2: Check Reuters Request Reply for ReutersDSS_Terms_and_Conditions

    #This is to generate the response filename which is driven by database sequence
    Given I execute below query and extract values of "SEQ_1" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ_1 FROM DUAL
        """

    And I execute below query and extract values of "SEQ_2" into same variables
        """
        SELECT LPAD(${SEQ_1}+1,8,'0') AS SEQ_2 FROM DUAL
        """

    And I execute below query and extract values of "SEQ_3" into same variables
        """
        SELECT LPAD(${SEQ_1}+2,8,'0') AS SEQ_3 FROM DUAL
        """

    And I execute below query and extract values of "SEQ_4" into same variables
        """
        SELECT LPAD(${SEQ_1}+3,8,'0') AS SEQ_4 FROM DUAL
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
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_3}' || '.xml' AS REQUEST_FILE_NAME_2
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Reuters_Composite'
        """
    And I execute below query and extract values of "UND_REQUEST_FILE_NAME_1" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_2}' || '.xml' AS UND_REQUEST_FILE_NAME_1
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'ReutersDSS_Terms_and_Conditions'
        """

    And I execute below query and extract values of "UND_REQUEST_FILE_NAME_2" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_4}' || '.xml' AS UND_REQUEST_FILE_NAME_2
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
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_3}' || '.csv' AS RESPONSE_FILE_NAME_2
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Reuters_Composite'
        """

    # Clear VREQ
    And I execute below query
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND
	VND_RQST_XREF_ID_CTXT_TYP = 'SED' AND VND_RQST_XREF_ID IN ('6368360','B0XGGY0','BFWB6B8','4354350','BD2NDJ7')
	"""

    And I execute below query
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND
	VND_RQST_XREF_ID_CTXT_TYP = 'RIC' AND VND_RQST_XREF_ID IN ('SNTO.KL','BBL.BK','TERNI.UNL')
	"""

    And I assign "${dmp.ssh.inbound.path}/reuters" to variable "RT_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/reuters" to variable "RT_PATH_OUT"
    And I assign "${dmp.ssh.outbound.path}/reuters/done" to variable "RT_PATH_DONE"

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply
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

    Given I copy files below from local folder "${testdata.path}/request/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_terms_conditions.xml |
    And I copy files below from local folder "${testdata.path}/request/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_composite.xml |

    Then I rename file "${RT_PATH_DONE}/gs_terms_conditions.xml" as "${RT_PATH_DONE}/${UND_REQUEST_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_DONE}/gs_composite.xml" as "${RT_PATH_DONE}/${UND_REQUEST_FILE_NAME_2}" in the named host "dmp.ssh.inbound"

    Given I process ReutersDSSWrapper workflow with below parameters and wait for the job to be completed
      | FILTER_REQ       | N              |
      | POSITIONS_SOURCE | BRSEOD         |
      | RT_DOWNLOAD_DIR  | ${RT_PATH_IN}  |
      | RT_UPLOAD_DIR    | ${RT_PATH_OUT} |
      | HST_REAS_TYP     | NONLATAM       |

     #This check to verify if only 5 securities which satisfied condition for ReutersDSS_Terms_and_Conditions were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 10   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND   VND_RQST_XREF_ID_CTXT_TYP = 'SED' AND   VND_RQST_XREF_ID IN (
         '6368360','B0XGGY0','BFWB6B8','4354350','BD2NDJ7'
      )
     """

    Then I expect value of column "VREQ_STATUS_CHECK_UNDERLYING" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 6   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK_UNDERLYING
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND   VND_RQST_XREF_ID_CTXT_TYP = 'RIC' AND   VND_RQST_XREF_ID IN (
         'SNTO.KL','BBL.BK','TERNI.UNL'
      )
     """

  Scenario: TC_5: Teardown test data

    Given I execute below query
     """
     ${testdata.path}/sql/teardown_testdata.sql
     """