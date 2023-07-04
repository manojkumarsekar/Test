#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_shell_security @tom_4090
Feature: 006 | Orders | Create Shell Security if Security is unavailable and Capture Order Details

  =============================================================================================================================================
  Expected Output :
  Set up shell Security
  Order details should be processed and sent to STARCOM
  Below Table Depicts Snapshot of Order Details
  =============================================================================================================================================
  FUND   | BCUSIP	   | ORDER ENTRY TIME	| ORDER ID | TRN_TYP | QUANTITY
  ALGEMB | WNU820185 | 03-AUG-18 10:10:34 | A1335004 | SELL    | -15
  =============================================================================================================================================

  Scenario: If underlying security is missing, create shell security and process order details
  Expected Output :  New security is set up, Order is processed and published to STARCOM in Intraday Processing

  #Pre-requisite : End Date Instrument and Clear Intraday Automation Orders
    Given I execute below query
	"""
    UPDATE FT_T_ISID SET END_TMS = SYSDATE, START_TMS = SYSDATE -2, LAST_CHG_USR_ID = 'AUTO:ORDERS' WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'WNU820185' AND END_TMS IS NULL);
    UPDATE FT_T_MKIS SET END_TMS = SYSDATE, START_TMS = SYSDATE -2, LAST_CHG_USR_ID = 'AUTO:ORDERS' WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'WNU820185' AND END_TMS IS NULL);
    UPDATE FT_T_MIXR SET END_TMS = SYSDATE, START_TMS = SYSDATE -2, LAST_CHG_USR_ID = 'AUTO:ORDERS' WHERE MKT_ISS_OID IN (SELECT MKT_ISS_OID FROM FT_T_MKIS WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'WNU820185' AND END_TMS IS NULL));
    COMMIT
	"""

    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('A1335004') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
	"""

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "006_esi_order_Shell_Security.xml" to variable "INPUT_FILENAME"
    And I assign "006_ESI_Orders_Shell_Security" to variable "PUBLISHING_FILE_NAME"
    And I assign "006_ESI_Orders_Shell_Security_Master_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "006_ESI_Orders_Shell_Security_Master.csv" to variable "MASTER_FILE"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST SPLIT ORDERS"
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

  #Verify Data

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_ISID
    WHERE ISS_ID = 'WNU820185'
    AND ID_CTXT_TYP = 'BCUSIP'
    AND END_TMS IS NULL
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1335004')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NULL
    """

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    And I create input file "${MASTER_FILE}" using template "${MASTER_TEMPLATE}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/006_exceptions_${recon.timestamp}.csv" file