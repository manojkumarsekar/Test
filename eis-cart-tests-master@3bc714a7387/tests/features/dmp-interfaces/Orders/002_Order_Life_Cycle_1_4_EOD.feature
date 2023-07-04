#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change
#tom_3795 : Remove T-1 intraday order publishing from EOD Orders

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_life_cycle @esi_orders_lifecycle_1_4_eod @tom_4090 @tom_3795
Feature: 002 | Orders | Capture Order Life Cycle EOD Day 1 Run 4

  =============================================================================================================================================
  Order status
  =============================================================================================================================================
  OrderNum | Intraday 1   | Intraday 2 | Intraday 3 | EOD 1      | Intraday 4 | Intraday 5 |  EOD 2
  A1230046 | COMPLPENDING | OPEN       | AUTHORIZED | AUTHORIZED | ACTIVE     | BOOKED     |  BOOKED
  A1230146 |              |            |            |            | ACTIVE     | BOOKED     |  BOOKED
  A1404713 | AUTHORIZED   | ACTIVE     | BOOKED     | BOOKED     |            |            |
  A1402744 | ACTIVE       | CANCELLED  |            | CANCELLED  |            |            |
  A1402644 | ACTIVE       | EXPIRED    |            | EXPIRED    |            |            |
  A1278682 | OPEN         |            |            | OPEN       |            |            |
  =============================================================================================================================================

  Scenario: Capture Order Life Cycle for Different Orders

  Expected Output :

  OrderId A1230046, A1278682 should be sent to STARCOM
  Exclude Intraday BOOKED, EXPIRED and CANCELLED orders A1404713, A1404813, A1402744, A1402644

  #Pre-requisite

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "002_esi_order_Order_Life_Cycle_EOD1.xml" to variable "INPUT_FILENAME"
    And I assign "002_ESI_Orders_Order_Life_Cycle_1_4_EOD" to variable "PUBLISHING_FILE_NAME"
    And I assign "002_EOD1_Template_1.csv" to variable "EOD1_TEMPLATE_1"
    And I assign "002_EOD1_1.csv" to variable "EOD1_1"


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
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID = 'A1230046'
    AND AOST.ORDER_STAT_TYP = 'AUTHORIZED'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID = 'A1404713'
    AND AOST.ORDER_STAT_TYP = 'BOOKED'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID = 'A1402744'
    AND AOST.ORDER_STAT_TYP = 'CANCELLED'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID = 'A1402644'
    AND AOST.ORDER_STAT_TYP = 'EXPIRED'
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID = 'A1278682'
    AND AOST.ORDER_STAT_TYP = 'OPEN'
    """

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data

    And I create input file "${EOD1_1}" using template "${EOD1_TEMPLATE_1}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    And I create input file "${EOD1_2}" using template "${EOD1_TEMPLATE_2}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect each record in file "${TESTDATA_PATH}/outfiles/testdata/${EOD1_1}" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_4_1_exceptions_${recon.timestamp}.csv" file