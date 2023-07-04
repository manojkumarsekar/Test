#https://jira.intranet.asia/browse/TOM-4231

@tom_4231 @dmp_twrr_functional @dmp_tw_functional @dmp_gs_upgrade
Feature: Test Research Report

  Scenario: TC-1 :Load portfolio Template with Main portfolio details to Setup new accounts in DMP

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport/order" to variable "TESTDATA_PATH"
    And I assign "Portfolio_with_s.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "esi_orders_without_s_template.xml" to variable "INPUT_TEMPLATE_FILENAME_1"
    And I assign "esi_orders_with_s_template.xml" to variable "INPUT_TEMPLATE_FILENAME_2"
    And I assign "esi_orders_without_s.xml" to variable "INPUT_FILENAME_1"
    And I assign "esi_orders_with_s.xml" to variable "INPUT_FILENAME_2"
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "ORDER_WORKFLOW"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/request.xmlt" to variable "RESEARCHREPORT_WORKFLOW"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    And I modify date "${SYSTEM_DATE}" with "+0d" from source format "dd/MM/yyyy" to destination format "YYYY-MM-dd" and assign to "DATE"

    And I create input file "${INPUT_FILENAME_1}" using template "${INPUT_TEMPLATE_FILENAME_1}" from location "${TESTDATA_PATH}"
    And I create input file "${INPUT_FILENAME_2}" using template "${INPUT_TEMPLATE_FILENAME_2}" from location "${TESTDATA_PATH}"

    And I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    And I execute below query
    """
    ${TESTDATA_PATH}/sql/InsertIntoACGP.sql
    """

  Scenario: TC-2 : Clear Data
    Given I execute below query
	"""
    UPDATE FT_T_AOST SET ORDER_STAT_TYP= 'ACTIVE',
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE AUOR_OID IN (SELECT AUOR_OID FROM FT_T_AUOR WHERE PREF_ORDER_ID IN('343546','3435461') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER');
    COMMIT
    """

  #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN('343546','3435461') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

    When I send research report email for category "DAMTemplate.txt" to common mail box with below details
      | PORTFOLIO          | TSTTT16       |
      | TEMP_PORTFOLIO     | TT16          |
      | REPORT_DATE        | ${DATE}       |
      | CUSIP              | SBF55Y570     |
      | TW_Buy_Sell        | Buy           |
      | PRICE              | 3750          |
      | LINK               | ${VAR_RANDOM} |
      | Target_Price_Lower | 2345          |
      | Target_Price_Upper | 5240          |
      | NEW_END_DATE       |               |

#Load Data
  Scenario: TC-3: Run the workflow for file 1

    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
    Then I extract value from the xml file "${TESTDATA_PATH}/testdata/${INPUT_FILENAME_1}" with tagName "CUSIP" to variable "BCUSIP"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "sneha.waje@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "SANITY TEST PUBLISH ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME_1}"
    And I set the workflow template parameter "POST_EVENT_NAME" to "EIS_UpdateInactiveOrder"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

  #Verify Data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID ='3435461'
    AND AOST.ORDER_STAT_TYP = 'OPEN'
    """


    Then I pause for 5 seconds

  Scenario: Run the ResearchResport workflow and test whether RSR1 and RSP1 setup.

    #Pre-requisite : Clear Orders
    Given I set the workflow template parameter "MESSAGE_TYPE" to "EITW_MT_RESEARCH_REPORT"
    And I set the workflow template parameter "BRS_WEBSERVICE_URL" to "${dmp.ssh.brswebservice.url}"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I pause for 5 seconds

  Scenario: Run the ResearchResport workflow and test whether RSR1 and RSP1 setup.

    Given I send research report email for category "DAMTemplate.txt" to common mail box with below details
      | PORTFOLIO          | TEST_4321_S   |
      | TEMP_PORTFOLIO     | TT16          |
      | REPORT_DATE        | ${DATE}       |
      | CUSIP              | SBF55Y570     |
      | TW_Buy_Sell        | Buy           |
      | PRICE              | 3750          |
      | LINK               | ${VAR_RANDOM} |
      | Target_Price_Lower | 2345          |
      | Target_Price_Upper | 5240          |
      | NEW_END_DATE       |               |

  Scenario: TC-4: Run the workflow for file 2

    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |
    Then I extract value from the xml file "${TESTDATA_PATH}/testdata/${INPUT_FILENAME_2}" with tagName "CUSIP" to variable "BCUSIP"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

  #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "sneha.waje@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "SANITY TEST PUBLISH ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME_2}"
    And I set the workflow template parameter "POST_EVENT_NAME" to "EIS_UpdateInactiveOrder"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

#Verify Data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID ='343546'
    AND AOST.ORDER_STAT_TYP = 'OPEN'
    """


    Then I pause for 5 seconds

  Scenario: Run the ResearchResport workflow and test whether RSR1 and RSP1 setup.

    #Pre-requisite : Clear Orders
    Given I set the workflow template parameter "MESSAGE_TYPE" to "EITW_MT_RESEARCH_REPORT"
    And I set the workflow template parameter "BRS_WEBSERVICE_URL" to "${dmp.ssh.brswebservice.url}"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I pause for 5 seconds


    Then I execute below query and extract values of "TASK_TOT_CNT;JOB_ID" into same variables
        """
        select TASK_TOT_CNT ,JOB_ID from (select * from fT_T_jblg  order by 4 desc) WHERE ROWNUM =1
        """

    Then I expect value of column "JOB_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS JOB_COUNT FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
        """