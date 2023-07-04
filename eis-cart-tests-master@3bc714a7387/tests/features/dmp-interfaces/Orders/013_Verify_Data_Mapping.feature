@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_verify_mapping @tom_3593 @dmp_gs_upgrade
Feature: 013 | Orders | Verify Data Mapping for Taiwan

  We are mapping below fields in DMP.
  This feature files is to verify that the data received in incoming file is mapped in DMP as expected

  Data Sample
  FUND   | BCUSIP    | ORDER ID	 | STATUS   |
  ALINDF | SB037HF18 | TST1725736 | ACTIVE  	|

  Scenario: TC_1: Clear old test data and setup variables

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "013_esi_orders.verify_mapping.xml" to variable "INPUT_FILENAME"
    And I assign "013_ESI_Orders_Verify_Mapping" to variable "PUBLISHING_FILE_NAME"

  #Pre-requisite :
    Given I execute below query to Clear Intraday Automation Orders
	"""
    ${TESTDATA_PATH}/sql/013_Clear_Intraday_Automation_Orders.sql
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
    And I set the workflow template parameter "FILE_PATTERN" to "013_esi_orders.verify_mapping.xml"
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

  Scenario: TC_2: Data Verifications

    # Verify Parent AUOR
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
     ${TESTDATA_PATH}/sql/013_Verify_Parent_AUOR_Data.sql
    """

    # Verify Child AUOR

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
	"""
     ${TESTDATA_PATH}/sql/013_Verify_Child_AUOR_Data.sql
    """

    # Verify AOPT
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    ${TESTDATA_PATH}/sql/013_Verify_Dealer_AOPT_Data.sql
    """

    # Verify AOST
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    ${TESTDATA_PATH}/sql/013_Verify_AOST_Data.sql
    """

    # Verify AOAR
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
      ${TESTDATA_PATH}/sql/013_Verify_AOAR_Data.sql
    """

    # Verify AOCM for comment reason type  BRSPMNOTE , BRSORDGRP

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":

    """
      ${TESTDATA_PATH}/sql/013_Verify_CmtReastyp_BRSPMNOTE_AOCM_Data.sql
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":

    """
      ${TESTDATA_PATH}/sql/013_Verify_CmtReastyp_BRSPMNOTE_AOCM_Data.sql
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "4":

    """
      ${TESTDATA_PATH}/sql/013_Verify_CmtReastyp_COMMENTS_AOCM_Data.sql
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