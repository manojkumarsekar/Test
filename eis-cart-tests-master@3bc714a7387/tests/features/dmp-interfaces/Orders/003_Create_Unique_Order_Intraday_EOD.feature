#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change
#eisdev_6348 : Thailand implementation :  https://jira.pruconnect.net/browse/EISDEV-6348
#              In the StarCompliance publishing from DMP, change the logic for memo field for Thailand portfolios.
#              Instead of publishing the investment manager location for Thailand, the entity name should be published
#              Portfolio should be looked up in the portfolio group mapping in DMP and publish the values as 'TMBAM' for TMBAM
#              portfolios(Group name : THB-AG) and 'TFUND' for TFUND portfolios(Group name : TFB-AG)
#              This is only applicable for Thailand portfolios.

@gc_interface_portfolios @gc_interface_orders
@dmp_regression_integrationtest
@dmp_thailand
@dmp_thailand_orders
@tom_3620 @esi_orders_create_unique_order @tom_4090 @eisdev_6348 @001_th_starcom @eisdev_6611
Feature: 003 | Orders | Create Unique Order received with same Security, Portfolio, Quantity and Entry time

   =============================================================================================================================================
   Problem Description :
   Two different orders(PM and Trader) are received with same Security, Portfolio, Quantity and Entry time.
   as per old interface modelling, Based on AUOR unique key condition only single record gets created at AUOR level and order information in AOID gets tagged to same AUOR.
   Since orders are merged, random order id gets published in the output file.
   =============================================================================================================================================
   Resolution :
   As part of TOM-3447 we have mapped PREF_ORDER_ID, PREF_ORDER_ID_CTXT_TYP column in AUOR to uniquely capture order information at AOUR level.
   Removed the mapping of ORDER_ID from AOID table.
   =============================================================================================================================================
   Below Table Depicts Snapshot of Order Details

   FUND   | BCUSIP	   | ORDER ENTRY TIME	| ORDER ID | TRN_TYP | QUANTITY
   ASPMSE | SB1VQ5C05 | 12-JUL-18 07:38:14 | A1229730 | SELL    | -150000
   ASPMSE | SB1VQ5C05 | 12-JUL-18 07:38:14 | A1229830 | SELL    | -150000

   ASPSEF | SB1VQ5C05 | 12-JUL-18 07:38:14 | A1229730 | SELL    | -150000
   ASPSEF | SB1VQ5C05 | 12-JUL-18 07:38:14 | A1229830 | SELL    | -150000

   ASPSDF | SB1VQ5C05 | 12-JUL-18 07:38:14 | A1229830 | SELL    | -25000

  eisdev_6348
   Capture Order Life Cycle for Thailand TMBAM(ordernum : A1111111, Fund : D22 ) and TFund(ordernum : A1111112, Fund : 38)
   Expected Output :  OrderId A1111111, A1111112 should be be sent to STARCOM along with below expected output


  Scenario: Create Unique order entry for orders received with same Security, Portfolio, Quantity and Entry time
  Expected Output : Create Unique order entry for orders A1229730 , A1229830
  Both Order details should be sent to STARCOM in Intraday Processing

    Given I execute below query to "Clear Intraday Automation Orders"
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('A1229730','A1229830','A1111111','A1111112') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
	"""

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "003_esi_order_Create_Unique_Order.xml" to variable "INPUT_FILENAME"
    And I assign "003_ESI_Orders_Create_Unique_Order" to variable "PUBLISHING_FILE_NAME"
    And I assign "003_ESI_Orders_Create_Unique_Order_EOD" to variable "PUBLISHING_FILE_NAME_EOD"
    And I assign "003_ESI_Orders_Create_Unique_Order_Master_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "003_ESI_Orders_Create_Unique_Order_Master.csv" to variable "MASTER_FILE"

    # Create Test Portfolios for Thailand orders
    And I assign "003_ESI_Orders_thailand_Portfolio_Setup.xlsx" to variable "PORTFOLIO_SETUP_FILE"

  # TFund Fund:38 does not have BRSFundId so creating this context type using File54 variable
    And I assign "003_ESI_Orders_thailand_F54_portfolio.xml" to variable "INPUT_F54_FILENAME"

  #Create the Test Portfolio
    When I process "${TESTDATA_PATH}/inputfiles/testdata/${PORTFOLIO_SETUP_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_SETUP_FILE}              |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "2"

  # Create BRSFundID as Context type using File54 from BRS for TFund
    When I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUT_F54_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_F54_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with total record count as "2"

    And I execute below query to create participants for TFund- TFB-AG group and TMBAM - THB-AG group
    """
    ${TESTDATA_PATH}/sql/003_InsertIntoACGPTable.sql
    """

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
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR WHERE PREF_ORDER_ID IN ('A1229730','A1229830','A1111111','A1111112') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER' AND ACCT_ID IS NULL
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR WHERE PREF_ORDER_ID IN ('A1229730')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('ASPMSE','ASPSEF') AND ACCT_ID_CTXT_TYP = 'CRTSID')
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR WHERE PREF_ORDER_ID IN ('A1229830')
    AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('ASPMSE','ASPSEF') AND ACCT_ID_CTXT_TYP = 'CRTSID')
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

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}                              |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |


  Scenario: Extract EOD Orders
  Expected Output : Both Order details should be sent to STARCOM in EOD Processing

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_EOD}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_EOD}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_EOD}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_EOD}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_EOD}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv     |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_EOD}_${VAR_SYSDATE}_1.csv |
