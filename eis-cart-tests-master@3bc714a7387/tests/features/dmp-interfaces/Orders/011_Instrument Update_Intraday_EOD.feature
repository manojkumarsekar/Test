#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_instrument_update @tom_4090
Feature: 011 | Orders | Instrument Update

  FUND   | BCUSIP    | ORDER ID| STATUS
  New:
  AHPESF | BRT7MJV79 | AAA07776 | ACTIVE

  Update:
  AHPESF | BRSS0BQJ5 | AAA07776 | ACTIVE

  Scenario: Underlying security for Order is updated from BRT7MJV79 to BRSS0BQJ5

  #Pre-requisite :
    # Clear Intraday Automation Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('AAA07776') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "011_esi_orders.Instrument_Update_1.xml" to variable "INPUT_FILENAME"
    And I assign "011_esi_orders.Instrument_Update_2.xml" to variable "INPUT_FILENAME_2"
    And I assign "011_ESI_Orders_Instrument_Update_1" to variable "PUBLISHING_FILE_NAME"
    And I assign "011_ESI_Orders_Instrument_Update_2" to variable "PUBLISHING_FILE_NAME_2"
    And I assign "011_ESI_Orders_Instrument_Update_1_Master_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "011_ESI_Orders_Instrument_Update_1_Master.csv" to variable "MASTER_FILE"
    And I assign "011_ESI_Orders_Instrument_Update_2_Master_Template.csv" to variable "MASTER_TEMPLATE_2"
    And I assign "011_ESI_Orders_Instrument_Update_2_Master.csv" to variable "MASTER_FILE_2"

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
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('AAA07776') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NULL
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID='BRT7MJV79' AND END_TMS IS NULL)
    """

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB |
      | BLANK_FILE           | true                              |

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

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/011_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Block Order with two allocation is split into two orders, Publish both orders to STARCOM, End-Date Inactive AOAR AND AUOR in EOD Processing

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST SPLIT ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "011_esi_orders.Instrument_Update_2.xml"
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
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('AAA07776') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NULL
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID='SBNB5WS69' AND END_TMS IS NULL)
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('AAA07776')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID='BRT7MJV79' AND END_TMS IS NULL)
    AND DATA_STAT_TYP = 'INACTIVE'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AOAR
    WHERE AUOR_OID IN
      (SELECT AUOR_OID FROM FT_T_AUOR WHERE PREF_ORDER_ID IN ('AAA07776')
      AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
      AND INSTR_ID IN
        (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID='BRT7MJV79' AND END_TMS IS NULL) AND DATA_STAT_TYP = 'INACTIVE')
    AND END_TMS IS NOT NULL
    """

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB |
      | BLANK_FILE           | true                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    And I create input file "${MASTER_FILE_2}" using template "${MASTER_TEMPLATE_2}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE_2}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/011_2_exceptions_${recon.timestamp}.csv" file