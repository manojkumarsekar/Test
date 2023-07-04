@tom_3700 @tom_3700_nosignorder @cis_op_regression @cis_op_functional

Feature: CISOrderPlacement | Functional | F011 | Test No dealer signature info Order in Publish Document workflow
  This is to test the no dealer signature info order

  Scenario: Load active order for E-SUN portfolio.

  #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "TESTDATA_PATH"
    And I assign "011_esi_nosign_activeorder_publish_document.xml" to variable "INPUT_FILENAME"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORDNUM"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

 #Pre-requisite : Clear Orders
    Given I execute below query
	"""
	${TESTDATA_PATH}order/sql/UPDATE_ORDER.sql
    """

    #Create ESUNPLTF for portfolio if not exists
    Given I execute below query
	"""
	${TESTDATA_PATH}order/sql/INSERT_Y_ESUNPLTF.sql
    """

  #Pre-requisite : Clear BRS attributes
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST NO SIGN ORDERS"
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

  Scenario: Run publish document workflow for active order

    #END TMS FPID signature
    Given I execute below query
	"""
    UPDATE FT_t_FPID FPID1
    set FPID1.END_TMS = SYSDATE
    WHERE FPID1.FINS_PRO_ID = (SELECT FPID.FINS_PRO_ID
    FROM FT_t_AUOR AUOR, FT_T_AOPT AOPT, FT_T_FPID FPID
    WHERE AUOR.AUOR_OID = AOPT.AUOR_OID
    AND AOPT.FPRO_OID = FPID.FPRO_OID
    AND AOPT.order_part_rl_typ ='Dealer'
    AND FPID.FINS_PRO_ID_CTXT_TYP = 'BRS_LOGIN'
    and fpid.end_tms is null
    and aopt.end_tms is null
    AND AUOR.PREF_ORDER_ID ='${ORDNUM}');
    COMMIT
  """

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}           |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    #Verify if PUB1 table row is created
    Then I expect value of column "PUB1COUNT" in the below SQL query equals to "1":
    """
      ${TESTDATA_PATH}order/sql/VERIFY_PUB1CNT.sql
    """

     #Verify if BRS attribute MONEYTRUSTID is created via API call
    Then I expect value of column "MONEYTRUSIDCOUNT" in the below SQL query equals to "1":
    """
       ${TESTDATA_PATH}order/sql/VERIFY_TWMNYTRSTCNT.sql
    """
  #Verify if BRS API Call transaction is closed succesfully
    Then I expect value of column "SUCCESSBRSAPITRIDCOUNT" in the below SQL query equals to "1":
    """
    ${TESTDATA_PATH}order/sql/VERIFY_SUCCESSBRSTRIDCNT.sql
    """

    #Verify if Insight Call transaction is closed succesfully
    Then I expect value of column "TRIDCOUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS TRIDCOUNT FROM FT_T_TRID WHERE
    CRRNT_SEVERITY_CDE = 50
    AND CRRNT_TRN_STAT_TYP = 'CLOSED'
    AND JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT ='Publish Insight Report Job')
      WHERE R=1)
    """

     #Verify if insight authentication exception is reported
    Then I expect value of column "NTELCOUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS NTELCOUNT FROM FT_T_NTEL
    WHERE  NOTFCN_ID = 60024
    AND MSG_SEVERITY_CDE = 50
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND CHAR_VAL_TXT LIKE 'Insight webservice call failed to get Insight report for CrossRefoid % with Status Code 50 and error text as Sign cannot be null'
    AND LAST_CHG_TRN_ID IN
      (SELECT TRID.TRN_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT = 'Publish Insight Report Job') JBLG, FT_T_TRID TRID
      WHERE JBLG.JOB_ID = TRID.JOB_ID AND R=1)
    """

   #Revert END TMS FPID signature
    Given I execute below query
	"""
    UPDATE FT_t_FPID FPID1
    set FPID1.END_TMS = NULL
    WHERE FPID1.FINS_PRO_ID = (SELECT FPID.FINS_PRO_ID
    FROM FT_t_AUOR AUOR, FT_T_AOPT AOPT, FT_T_FPID FPID
    WHERE AUOR.AUOR_OID = AOPT.AUOR_OID
    AND AOPT.FPRO_OID = FPID.FPRO_OID
    AND AOPT.order_part_rl_typ ='Dealer'
    AND FPID.FINS_PRO_ID_CTXT_TYP = 'BRS_LOGIN'
    and fpid.end_tms is not null
    and aopt.end_tms is null
    AND AUOR.PREF_ORDER_ID ='${ORDNUM}');
    COMMIT
  """

