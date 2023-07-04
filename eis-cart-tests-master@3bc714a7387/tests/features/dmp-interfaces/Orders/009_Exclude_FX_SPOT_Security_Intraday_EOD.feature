#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_exclude_fx_spot_security_intraday_eod @tom_4090
Feature: 009 | Orders | Exclude FX SPOT Security

  FUND   | BCUSIP	   | ORDER ENTRY TIME	  | ORDER ID | TRN_TYP | QUANTITY
  ALALBF | BPM1SQ5Y1 | 9/6/2018 1:05:32.656 | AU1454804 | BUY    | 90280000000
  ALINDF | S61396966 | 9/6/2018 4:54:22.036 | AU1358506 | BUY    | 925
  AIIEQP | S61396966 | 9/6/2018 4:54:22.036 | AU1358506 | BUY    | 34116

  Scenario: Orders related to excluded security group should not be sent to STARCOM in Intrday Processing.

  Expected Output :  Orders related to excluded security BPM1SQ5Y1 should not be sent to STARCOM

    # Clear Intraday Automation Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('AU1454804','AU1358506') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "009_esi_order_exclude_fx_intraday.xml" to variable "INPUT_FILENAME"
    And I assign "009_ESI_Orders_Exclude_FX_SPOT_Security_intraday" to variable "PUBLISHING_FILE_NAME"
    And I assign "009_ESI_Orders_Exclude_FX_SPOT_Security_eod" to variable "PUBLISHING_FILE_NAME_EOD"
    And I assign "009_ESI_Orders_Exclude_FX_SPOT_Security_Master_Template.csv" to variable "MASTER_TEMPLATE"
    And I assign "009_ESI_Orders_Exclude_FX_SPOT_Security_Master.csv" to variable "MASTER_FILE"

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

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR
    WHERE PREF_ORDER_ID IN ('A1454804','A1358506') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER'
    AND ACCT_ID IS NULL
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_ISCL WHERE
    INDUS_CL_SET_ID = 'SECGROUP'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM1SQ5Y1' AND END_TMS IS NULL)
    AND CL_VALUE IN (SELECT INTRNL_DMN_VAL_TXT FROM FT_T_IDMV WHERE FLD_ID = '41000701' AND FLD_DATA_CL_ID = 'STARCOM')
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
    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/009_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Orders related to excluded security group should not be sent to STARCOM in EOD Processing.

  Expected Output :  Orders related to excluded security BPM1SQ5Y1 should not be sent to STARCOM


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
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_EOD}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/009_2_exceptions_${recon.timestamp}.csv" file


