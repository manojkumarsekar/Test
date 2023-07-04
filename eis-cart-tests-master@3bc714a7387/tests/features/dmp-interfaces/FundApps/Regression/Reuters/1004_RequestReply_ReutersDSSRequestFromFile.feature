#https://jira.pruconnect.net/browse/EISDEV-7048

@gc_interface_securities
@dmp_regression_integrationtest
@eisdev_7048 @fa_inbound @09_inbound_rcr_ROBO @dmp_fundapps_functional @fund_apps_instrument @dmp_interfaces @dmp_fundapps_regression
Feature: To verify Reuters DSS Request from File for ROBO COLL

  Scenario: Check Reuters Request Reply for ReutersDSS_Terms_and_Conditions

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Reuters" to variable "testdata.path"

    Given I execute below query and extract values of "SEQ_1" into same variables
    """
    SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ_1 FROM DUAL
    """

    And I execute below query and extract values of "SEQ_2" into same variables
    """
    SELECT LPAD(${SEQ_1}+1,8,'0') AS SEQ_2 FROM DUAL
    """

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

    Given I execute below query to "Update VREQ to Dummy"
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP IN ('ReutersDSS_Terms_and_Conditions','EIS_Reuters_Composite') AND
	VND_RQST_XREF_ID_CTXT_TYP = 'SED' AND VND_RQST_XREF_ID = 'TSTRTS0'
	"""

    And I assign "${dmp.ssh.inbound.path}/reuters" to variable "RT_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/reuters" to variable "RT_PATH_OUT"
    And I assign "${dmp.ssh.outbound.path}/reuters/done" to variable "RT_PATH_DONE"

    Given I copy files below from local folder "${testdata.path}/request/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_terms_conditions_trdssfromfile.xml |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_IN}":
      | gs_terms_conditions_trdrssfromfile.csv |
    And I copy files below from local folder "${testdata.path}/request/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_DONE}":
      | gs_composite_trdssfromfile.xml |
    And I copy files below from local folder "${testdata.path}/response/template" to the host "dmp.ssh.inbound" folder "${RT_PATH_IN}":
      | gs_composite.csv |

    Then I rename file "${RT_PATH_DONE}/gs_terms_conditions_trdssfromfile.xml" as "${RT_PATH_DONE}/${REQUEST_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_IN}/gs_terms_conditions_trdrssfromfile.csv" as "${RT_PATH_IN}/${RESPONSE_FILE_NAME_1}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_DONE}/gs_composite_trdssfromfile.xml" as "${RT_PATH_DONE}/${REQUEST_FILE_NAME_2}" in the named host "dmp.ssh.inbound"
    And I rename file "${RT_PATH_IN}/gs_composite.csv" as "${RT_PATH_IN}/${RESPONSE_FILE_NAME_2}" in the named host "dmp.ssh.inbound"

  Scenario: File load BRS F10 to set up TW0002376001 with Sedol 6129181

    Given I assign "brs_f10_6129181.xml" to variable "BRS_INPUT_FILENAME"
    And I process "${testdata.path}/position/testdata/${BRS_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${BRS_INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Call Reuters Request From File workflow to set up Sedol TSTRTS0 with ISIN TW0002376001

    Given I assign "ROBOSBLPOSITIONS_TRDSSFromFile.csv" to variable "ROBO_INPUT_FILENAME"
    And I assign "ROBOSBLPOSITIONS_TRDSSFromFile_Template.csv" to variable "ROBO_TEMPLATE_FILENAME"

    And I execute below query and extract values of "DYNAMIC_DATE_SBL" into same variables
     """
     select to_char(max(GREG_DTE),'DD Mon YYYY') as DYNAMIC_DATE_SBL from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """

    And I create input file "${ROBO_INPUT_FILENAME}" using template "${ROBO_TEMPLATE_FILENAME}" from location "${testdata.path}/position"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TW0002376001'"

    And I copy files below from local folder "${testdata.path}/position/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ROBO_INPUT_FILENAME} |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ReutersDSSRequestFromFile/request.xmlt" to variable "RESUBMIT_EXCPTN_WF"
    And I assign "${dmp.ssh.inbound.path}/reuters" to variable "RT_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/reuters" to variable "RT_PATH_OUT"

    And I process the workflow template file "${RESUBMIT_EXCPTN_WF}" with below parameters and wait for the job to be completed
      | DIRECTORY       | ${dmp.ssh.inbound.path} |
      | FILE_PATTERN    | ${ROBO_INPUT_FILENAME}  |
      | RT_DOWNLOAD_DIR | ${RT_PATH_IN}           |
      | RT_UPLOAD_DIR   | ${RT_PATH_OUT}          |

  Scenario: File load for RCRLBU Position for Data Source ROBO Coll with Sedol TSTRTS0

    And I process "${testdata.path}/position/testdata/${ROBO_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${ROBO_INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION |
      | BUSINESS_FEED |                              |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verify ISIN TW0002376001, Sedol 6129181, Sedol TSTRTS0 and Robo Coll TSTRTS0 to same instrument
    Then I expect value of column "ISSU_COUNT" in the below SQL query equals to "1":
     """
      select count(distinct instr_id) as ISSU_COUNT from ft_t_isid where iss_id in ('TW0002376001','TSTRTS0','6129181') and end_tms is null
     """