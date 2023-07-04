#https://jira.intranet.asia/browse/TOM-4612
#https://jira.intranet.asia/browse/TOM-4677
#https://jira.intranet.asia/browse/TOM-4140 - ESUN acct opening date. This field's mapping has to be changed from acct.acct_open_dte to EXAC.ACCT_OPEN_DATE

@dmp_regression_integrationtest
@tom_4612 @tom_4677 @tw_order_placement @tom_4140  @tom_4902 @tom_4902_split
@cis_op_regression @cis_op_functional @eisdev_7439

Feature: CISOrderPlacement | Functional | F013_2 | CIS Order Placement Format 1 for split portfolio changes

  1. Load portfolio template and account opening date in exac
  2. Load new order
  3. Perform verification of data inserted
  4. Publish PDF document by calling workflow
  5. Verify whether PDF got published or not
  6. Fetch latest PDF file generated
  7. Compare the PDF file with expected PDF file

  Scenario: Clear data and assign variables

    #Pre-requisite : Clear Orders
    Given I execute below query
    """
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID = '2426892_TEST_FORMAT1' AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    UPDATE FT_T_CCRF SET END_TMS = SYSDATE
    WHERE  INSTR_ID=(SELECT ISID.INSTR_ID FROM FT_T_ISID ISID WHERE ISID.ID_CTXT_TYP = 'ISIN' AND ISID.END_TMS IS NULL  AND ISID.ISS_ID='TW000T4719Y8' ) AND
    END_TMS IS NULL;
    COMMIT
    """

    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "TESTDATA_PATH"
    And I assign "013_esi_orders.20190514_0445_format1.xml" to variable "INPUT_FILENAME"
    And I assign "4140_Portfolio_Template.xlsx" to variable "INPUT_FILENAME1"

    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | 2426892_TEST_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf* |

    #Create ESUNPLTF for portfolio if not exists
    Given I execute below query
    """
	${TESTDATA_PATH}order/sql/INSERT_ESUNPLTF_FOR_PORTOFLIO_FORMAT1.sql
    """

  Scenario: Load orders for portfolio.

    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}  |
      | ${INPUT_FILENAME1} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "SANITY TEST PUBLISH ORDERS"
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

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN ('2426892_TEST_FORMAT1')
    AND AOST.ORDER_STAT_TYP = 'ACTIVE'
    """

  Scenario: Test BRS API Call & Publish document by doing a API call to Insight

    #Pre-requisite : Clear Orders
    Given I process "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}             |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN ('2426892_TEST_FORMAT1')
    AND AOST.ORDER_STAT_TYP = 'NEWSENT'
    AND GEN_CNT = ( SELECT MAX (GEN_CNT) FROM FT_T_AOST AOST1 WHERE AOST1.AUOR_OID = AUOR.AUOR_OID)
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | 2426892_TEST_FORMAT1_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | 2426892_TEST_FORMAT1_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |

  Scenario: Loading PDF file in local and performing direct PDF comparison with expected PDF

    Given I assign "ORDER_PLACEMENT_FORMAT1_SPLIT_PORTFOLIO_BASE.pdf" to variable "EXPECTED_FILE"

    When I read latest file with the pattern "2426892_TEST_FORMAT1_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf" in the path "${PUBLISHING_DIRECTORY}" with the host "dmp.ssh.inbound" into variable "LATEST_FILE_NAME"

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/order/outfiles/runtime":
      | "${LATEST_FILE_NAME}" |

    Then I expect below pdf files should be identical
      | ${TESTDATA_PATH}/order/outfiles/expected/${EXPECTED_FILE}   |
      | ${TESTDATA_PATH}/order/outfiles/runtime/${LATEST_FILE_NAME} |