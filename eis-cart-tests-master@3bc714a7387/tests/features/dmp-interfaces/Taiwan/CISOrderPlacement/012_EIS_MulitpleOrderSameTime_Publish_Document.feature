@tom_3700 @tom_3700_multipleorders @cis_op_regression @cis_op_functional

Feature: CISOrderPlacement | Functional | F012 | Test multiple order loading at same time in Publish Document workflow
  This is to test multiple order loading at same time

  Scenario: Load active order for E-SUN portfolio.

  #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "TESTDATA_PATH"
    And I assign "012_esi_activeorder_publish_document_1_030120191001.xml" to variable "INPUT_FILENAME1"
    And I assign "012_esi_activeorder_publish_document_2_030120191002.xml" to variable "INPUT_FILENAME2"
    And I assign "012_esi_activeorder_publish_document_3_030120191003.xml" to variable "INPUT_FILENAME3"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME2} |

    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME3} |

    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME1}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME1}" with tagName "ORD_NUM" to variable "ORDNUM"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME1}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ORDNUM}_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ORDNUM}_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |

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
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST MULITPLE ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "012_esi_activeorder_publish_document*.xml"
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
    Then I expect value of column "SUCCESSINSIGHTTRIDCOUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SUCCESSINSIGHTTRIDCOUNT FROM FT_T_TRID WHERE
     MAIN_ENTITY_ID = (SELECT AUOR_OID FROM FT_T_AUOR WHERE PREF_ORDER_ID = '${ORDNUM}' AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER' AND ACCT_ID IS NOT NULL AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ORDERS')
    AND MAIN_ENTITY_ID_CTXT_TYP = 'AUOR_OID'
    AND MAIN_ENTITY_TYP = 'AUOR'
    AND MAIN_ENTITY_TBL_TYP = 'AUOR'
    AND CRRNT_SEVERITY_CDE = 0
    AND CRRNT_TRN_STAT_TYP = 'CLOSED'
    AND JOB_ID IN
      (SELECT JOB_ID FROM
      (SELECT JOB_ID, ROW_NUMBER() OVER (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_CONFIG_TXT ='Publish Insight Report Job')
      WHERE R=1)
    """

    #Verify Order status
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID  = '${ORDNUM}'
    AND AOST.ORDER_STAT_TYP = 'NEWSENT'
    AND AUOR.ORDER_CQTY = '800'
    AND GEN_CNT = ( SELECT MAX (GEN_CNT) FROM FT_T_AOST AOST1 WHERE AOST1.AUOR_OID = AUOR.AUOR_OID)
    """

 #Verify presence of Insight report
    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${ORDNUM}_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${ORDNUM}_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |


