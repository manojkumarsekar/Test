#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change
#tom_3795 : Remove T-1 intraday order publishing from EOD Orders

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_exclude_black_listed_portfolio_intraday @tom_4090 @tom_3795
Feature: 007 | Orders | Exclude Blacklisted Portfolios Intraday

  =============================================================================================================================================
  FUND   | BCUSIP	   | ORDER ENTRY TIME	  | ORDER ID | TRN_TYP | QUANTITY
  ALALBF | BRSE1FYJ7 | 9/6/2018 1:05:32.656 | A1454804 | BUY    | 90280000000
  ALINDF | S61396966 | 9/6/2018 4:54:22.036 | A1358506 | BUY    | 925
  AIIEQP | S61396966 | 9/6/2018 4:54:22.036 | A1358506 | BUY    | 34116
  ALINDF | BRSE1FYJ7 | 9/6/2018 4:54:22.036 | AA154100 | BUY    | 90280000000
  =============================================================================================================================================
  Expected Output :
  A1454804 : Fund ALALBF is not part of exclusion list - Order should be published
  A1358506 : Fund  AIIEQP is not part of exclusion list and ALINDF is part of exclusion list - Order should be published
  AA154100 : Fund ALINDF is part of exclusion list - Order should NOT be published
  =============================================================================================================================================

  Scenario: Orders related to excluded portfolios should not be sent to STARCOM in Intrday Processing. Configure portfolio ALINDF to the STARPRDEXCLPORT group

    #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "007_esi_order_exclude_blacklisted_portfolios_intraday.xml" to variable "INPUT_FILENAME"
    And I assign "007_ESI_Orders_Non_Blacklisted_Portfolios" to variable "PUBLISHING_FILE_NAME"
    And I assign "007_008_ESI_Orders_Non_Blacklisted_Portfolios_Master_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "007_ESI_Orders_Non_Blacklisted_Portfolios_Master.csv" to variable "MASTER_FILE"


  #Pre-requisite :
    # Clear Intraday Automation Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('AA154100','A1454804','A1358506') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

    # Add Fund to Blacklist
    Given I execute below query
	"""
	${TESTDATA_PATH}/sql/007_INSERT_EXCLUDE_PORTFOLIO.sql
    """

   #Verify ACGP
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_ACGP ACGP WHERE ACGP.PRNT_ACCT_GRP_OID =
    (
        SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'STARPRDEXCLPORT'
        AND ORG_ID IS NULL
        AND SUBDIV_ID IS NULL
        AND SUBD_ORG_ID IS NULL
    )
    AND ACGP.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALINDF' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS IS NULL)
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

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1454804','A1358506','AA154100') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
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
    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/007_exceptions_${recon.timestamp}.csv" file

