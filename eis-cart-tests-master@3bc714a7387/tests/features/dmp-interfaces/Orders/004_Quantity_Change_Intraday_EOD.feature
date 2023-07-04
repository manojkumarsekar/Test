#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change
#tom_3795 : Remove T-1 intraday order publishing from EOD Orders
#tom_4132 : Updated workflow parameter for Load and Publish Exception Job

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_exclude_quantity @tom_4090 @tom_3795 @tom_4132
Feature: 004 | Orders | Create Order received with different Quantity for same Security and Portfolio

  =============================================================================================================================================
  Problem Description :
  Order can be BOOKED/SPLIT with different quantity
  Based on AUOR unique key condition different record gets created at AUOR level
  Since Order is BOOKED under new AUOR, Order Status of the first AUOR remains orphan and gets published in EOD file as OPEN
  =============================================================================================================================================
  Resolution :
  As part of TOM-3499 mapped custom match key to exclude ORDER_CQTY column in AUOR to create single AUOR
  As part of TOM-3757 we removed the match key
  =============================================================================================================================================
  Expected Output :
  If Order is sent with a different quantity, Parent quantity should be overridden in the database.
  New allocation order entry should be created and update inactive processor should inactivate older AUOR and AOAR entries

  New: ACTIVE Order A1179994
  FUND   | BCUSIP	   | ORDER ENTRY TIME	| ORDER ID | TRN_TYP | QUANTITY | ORDER_STATUS
  AMICEO | SB5Q3JZ51 | 01-JUN-18 04:54:13 | A1179994 | SELL    | -12459   | ACTIVE
  AIIEQP | SB5Q3JZ51 | 01-JUN-18 04:54:13 | A1179994 | SELL    | -32539   | ACTIVE
  ALINDF | SB5Q3JZ51 | 01-JUN-18 04:54:13 | A1179994 | SELL    | -240	    | ACTIVE

  Update: BOOKED Order A1179994
  FUND   | BCUSIP	   | ORDER ENTRY TIME   | ORDER ID | TRN_TYP | QUANTITY | ORDER_STATUS
  AMICEO | SB5Q3JZ51 | 01-JUN-18 04:54:13 | A1179994 | SELL    | -5152    | BOOKED
  AIIEQP | SB5Q3JZ51 | 01-JUN-18 04:54:13 | A1179994 | SELL    | -13457   | BOOKED
  ALINDF | SB5Q3JZ51 | 01-JUN-18 04:54:13 | A1179994 | SELL    | -99	    | BOOKED

  Scenario: New ACTIVE Order A1179994 for Fund AMICEO, AIIEQP and ALINDF
  Expected Output : OrderId A1179994 should be sent to STARCOM


    Given I execute below query to "Clear Intraday Automation Orders"
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('A1179994') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
	"""

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "004_esi_order_Quantity_Change_1.xml" to variable "INPUT_FILENAME"
    And I assign "004_esi_order_Quantity_Change_2.xml" to variable "INPUT_FILENAME_2"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_1_Intraday" to variable "PUBLISHING_FILE_NAME"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_2_Intraday" to variable "PUBLISHING_FILE_NAME_2"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_3_EOD" to variable "PUBLISHING_FILE_NAME_3"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_1_Intraday_Master_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_1_Intraday_Master.csv" to variable "MASTER_FILE"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_2_Intraday_Master_Template.csv" to variable "MASTER_TEMPLATE_2"
    And I assign "004_ESI_Orders_Exclude_Quantity_Match_Key_1_2_Intraday_Master.csv" to variable "MASTER_FILE_2"
    And I assign "004_EOD3_Template_1.csv" to variable "EOD3_TEMPLATE_1"
    And I assign "004_EOD3_1.csv" to variable "EOD3_1"

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
    WHERE PREF_ORDER_ID IN ('A1179994')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NULL
    AND ORDER_CQTY = '-45238'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1179994')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NOT NULL
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
    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/004_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Order A1179994 BOOKED for Fund AMICEO, AIIEQP and ALINDF with different quantity
  Expected Output : Quantity is updated and single record remains in database. Order is sent to Starcom

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
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1179994')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NULL
    AND ORDER_CQTY = '-18708'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1179994')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NOT NULL
    AND DATA_STAT_TYP = 'INACTIVE'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1179994')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NOT NULL
    AND DATA_STAT_TYP IS NULL
    """

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    And I create input file "${MASTER_FILE_2}" using template "${MASTER_TEMPLATE_2}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE_2}                              |

  Scenario: Extract EOD Orders
  Expected Output :
  File contains all orders for latest Modify Time(AOST.STAT_TMS) and, if the respective orders having status as P=Open, U=authorized, A=active, O=Compliance Pending
  OrderId A1179994 for all 3 portfolios should not be sent to STARCOM

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_3}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

    Then I expect none of the records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

