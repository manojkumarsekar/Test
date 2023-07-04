@tom_3700 @tom_3700_insightauthenfail @cis_op_regression @cis_op_functional

Feature: CISOrderPlacement | Functional | F005 | Test Insight Authentication failure in Publish Document workflow
  This is to test when user credentials are incorrect for Insight then report fails

  Scenario: Load order for E-SUN portfolio.

  #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "TESTDATA_PATH"
    And I assign "005_esi_orders_publish_document.xml" to variable "INPUT_FILENAME"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORDNUM"

 #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    ${TESTDATA_PATH}order/sql/UPDATE_ORDER.sql
    """

  #Pre-requisite : Clear BRS attributes
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST Insight fail scenario"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
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

  #Verify Order data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
     ${TESTDATA_PATH}order/sql/VERIFY_BRSORDERSTATUS.sql
    """

  Scenario: Test if insight authentication fails

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB            |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                      |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}       |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}             |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.invalidfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                   |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                   |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}      |

    #Verify if PUB1 table row is created with failed status
    Then I expect value of column "INSIGHTFAILPUB1COUNT" in the below SQL query equals to "1":
    """
    ${TESTDATA_PATH}order/sql/005_VERIFY_INSIGHTFAILPUB1CNT.sql
    """

     #Verify if insight transaction is closed succesfully
    Then I expect value of column "TRIDCOUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS TRIDCOUNT FROM FT_T_TRID
    WHERE CRRNT_TRN_STAT_TYP = 'CLOSED'
     AND JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT = 'Publish Insight Report Job')
      WHERE R=1)
    AND CRRNT_SEVERITY_CDE = 50
    """

     #Verify if insight authentication exception is reported
    Then I expect value of column "INSIGHTFAILNTELCOUNT" in the below SQL query equals to "1":
    """
    ${TESTDATA_PATH}order/sql/005_VERIFY_INSIGHTFAILNTELCNT.sql
    """

    #Verify if insight job is failed succesfully
    Then I expect value of column "JOBFAILCOUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS JOBFAILCOUNT
     FROM (SELECT JBLG.JOB_STAT_TYP AS STATTYP, ROW_NUMBER() OVER (PARTITION BY JBLG.JOB_INPUT_TXT ORDER BY JBLG.JOB_START_TMS DESC) R
      FROM FT_T_JBLG JBLG WHERE JBLG.JOB_CONFIG_TXT = 'Publish Insight Report Job')
      WHERE R=1 AND STATTYP = 'FAILED'
    """

    #Verify Order status
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RECORD_COUNT
    FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN ('$ORDNUM')
    AND AOST.ORDER_STAT_TYP IN( 'NEWSENT', 'NEWPEND')
    AND GEN_CNT = ( SELECT MAX (GEN_CNT) FROM FT_T_AOST WHERE AUOR.PREF_ORDER_ID IN ('$ORDNUM'))
    """
