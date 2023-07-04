#https://jira.intranet.asia/browse/TOM-4272

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_verify_mapping @tom_4272
Feature: 018 | Orders | Verify No Active Order After ProcTms Mapping and publishing

  This feature file tests that the reload of order after changing ACTIVE_TIME field, updates the child order and does not create a new one.
  Also, tests that the published file gives the timezone for Investment Manager.

  Scenario:  Clear old test data and setup variables

  Data Sample
  FUND   | BCUSIP    | ORDER ID	 | STATUS   |
  ALINDF | SB037HF18 | TST1817257 | ACTIVE  	|

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "018_esi_orders.xml" to variable "INPUT_FILENAME"
    And I assign "018_ESI_Orders_Verify_NoInactiveOrder" to variable "PUBLISHING_FILE_NAME"
    And I assign "018_ESI_Orders_VerifyNoInactiveOrder_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "018_ESI_Orders_VerifyNoInactiveOrder_MasterFile.csv" to variable "MASTER_FILE"

    Then I extract value from the xml file "${TESTDATA_PATH}/inputfiles/testdata/${INPUT_FILENAME}" with tagName "ORD_NUM" to variable "ORD_NUM"
    Then I extract value from the xml file "${TESTDATA_PATH}/inputfiles/testdata/${INPUT_FILENAME}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIO_NAME"

  #Pre-requisite :
    # Clear Intraday Automation Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('${ORD_NUM}') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "LOAD ORDER"
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

  Scenario:  Data Verifications

    # Verify Parent AUOR

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS RECORD_COUNT
     FROM ft_t_auor WHERE
     pref_order_id = '${ORD_NUM}' AND acct_id IS NULL
     AND instr_id IN ( SELECT instr_id FROM ft_t_isid WHERE iss_id = 'SB037HF18' AND id_ctxt_typ = 'BCUSIP')
     AND   order_proc_tms = TO_DATE('03-DEC-2018 05:27:06','DD-MON-YYYY HH24:MI:SS')
    """

    # Verify Child AUOR

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
	"""
    SELECT COUNT(*) AS RECORD_COUNT
    FROM ft_t_auor WHERE
    pref_order_id = '${ORD_NUM}'
    AND  acct_id IN ( SELECT acct_id FROM ft_t_acid WHERE acct_alt_id IN ('${PORTFOLIO_NAME}'))
    AND   order_proc_tms = TO_DATE('03-DEC-2018 05:27:06','DD-MON-YYYY HH24:MI:SS')
    """

  Scenario: Load order again after changing ACTIVE_TIME field mapped to ORDER_PROC_TMS
  Expectation: child order should be updated with new value for ORDER_PROC_TMS and not create new order

    And I assign "018_esi_orders.activetimechange.xml" to variable "INPUT_FILENAME1"

    #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

  #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST NO INACTIVE ORDER"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME1}"
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

  Scenario: Data Verifications

  # Verify Parent AUOR

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS RECORD_COUNT
     FROM ft_t_auor WHERE
     pref_order_id = '${ORD_NUM}' AND acct_id IS NULL
     AND instr_id IN ( SELECT instr_id FROM ft_t_isid WHERE iss_id = 'SB037HF18' AND id_ctxt_typ = 'BCUSIP')
     AND   order_proc_tms = TO_DATE('04-DEC-2018 05:27:06','DD-MON-YYYY HH24:MI:SS')
    """

    # Verify Child AUOR

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
	"""
    SELECT COUNT(*) AS RECORD_COUNT
    FROM ft_t_auor WHERE
    pref_order_id = '${ORD_NUM}'
    AND  acct_id IN ( SELECT acct_id FROM ft_t_acid WHERE acct_alt_id IN ('${PORTFOLIO_NAME}'))
    AND   order_proc_tms = TO_DATE('04-DEC-2018 05:27:06','DD-MON-YYYY HH24:MI:SS')
    """

  Scenario: Publish order file
  #Extract Data
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    #Reconcile Data
    And I create input file "${MASTER_FILE}" using template "${MASTER_TEMPLATE}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/018_1_1_exceptions_${recon.timestamp}.csv" file
