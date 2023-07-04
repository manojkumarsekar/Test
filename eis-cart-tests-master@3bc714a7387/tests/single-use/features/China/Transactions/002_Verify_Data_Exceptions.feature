# =======================================================================================================
# Feature History
# Technical Document : https://collaborate.intranet.asia/display/TOM/WFOE+-+Transactions#Test-testScenario
# TOM-4195 : Initial Version of feature file
# TOM-4316 : Handle Exception for TRADE_STATUS=CANCEL
# EISDEV-5400: Modified RCRLBU connector to load GP & RCR files. Hence, the transformation is not required anymore
# =======================================================================================================

@dmp_wfoe @dmp_wfoe_transactions @dmp_wfoe_transactions_verify_exceptions @tom_4205 @tom_4316
Feature: 002 | China-WFOE | Transactions | Verify In-Memory Data Exceptions

  Scenario: Throw Exception if "CLIENT_SEC_TYPE" has value other than the configured RCR Security Type. Transactions data will not be transformed and published

    Given I assign "002_esi_sc_transactions_verify_exceptions.csv" to variable "INPUT_FILENAME"
    And I assign "WFOEEISLTRANSN" to variable "OUTPUT_FILENAME"
    And I assign "001_002_WFOEEISLTRANSN_TEMPLATE.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/fundapps" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/single-use/China/Transactions" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${OUTPUT_FILENAME}* |

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform file
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EICN_MT_RCR_TRANSACTIONS"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I execute below query and extract values of "JOB_ID" into same variables
      """
        SELECT job_id AS JOB_ID
        FROM ft_t_jblg
        WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    And I rename file "${PUBLISHING_DIR}/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" as "${PUBLISHING_DIR}/002_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | 002_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    #Reconcile output file with the standard template file. Failed Records are not published
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/002_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${MASTER_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

    #Verify Exception in NTEL
    Then I expect value of column "EXCEPTION_VALID_RCRSECTYP" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_VALID_RCRSECTYP FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '2')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as incoming CLIENT_SEC_TYPE = INVALIDSEC is not valid RCR - Security Type'
    """

  Scenario: Throw Exception if Domains for "TRANSACTION" are not available in DMP, Transactions data will not be transformed and published

    #Verify Exception in NTEL for Invalid Transaction Type
    Then I expect value of column "INVALID_TRN_TYP" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INVALID_TRN_TYP FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '17')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT like 'User defined Error thrown! . Cannot process record as incoming TRANSACTION = INVALIDTRNTYP is not valid RCR - Transaction Type'
    """

  Scenario: Throw Exception if Domains for "TRADE_STATUS" is CANC, Transactions data will not be transformed and published

    #Verify Exception in NTEL for Invalid Transaction Type
    Then I expect value of column "CANC_TRADE_STATUS" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS CANC_TRADE_STATUS FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '18')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT like 'User defined Error thrown! . Cannot process record as incoming TRADE_STATUS = CANC is not valid Trade Status'
    """

  Scenario: Throw Exception if "TRADE_DATE" has invalid date, Transactions data will not be transformed and published

    #Verify Exception in NTEL for INVALID_TRADE_DATE : 20562441
    Then I expect value of column "INVALID_TRADE_DATE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INVALID_TRADE_DATE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '14')
    AND MSG_SEVERITY_CDE = 50
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT like '%Function %ReformatDateTime% Parameter Nr.: 1 Error: 20562441 Format String: %Y%M%D%021111%'
    """

  Scenario: Throw Exception if "EXECUTION_DATE" has invalid date, Transactions data will not be transformed and published

    #Verify Exception in NTEL for INVALID_EXECUTION_DATE  : 20562441
    Then I expect value of column "INVALID_EXECUTION_DATE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INVALID_EXECUTION_DATE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '15')
    AND MSG_SEVERITY_CDE = 50
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT like '%Function %ReformatDateTime% Parameter Nr.: 1 Error: 20562441 Format String: %Y%M%D%031111%'
    """

  Scenario: Throw Exception if "SETTLE_DATE" has invalid date, Transactions data will not be transformed and published

    #Verify Exception in NTEL for INVALID_SETTLE_DATE  : 20562441
    Then I expect value of column "INVALID_SETTLE_DATE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INVALID_SETTLE_DATE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '16')
    AND MSG_SEVERITY_CDE = 50
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT like '%Function %ReformatDateTime% Parameter Nr.: 1 Error: 20562441 Format String: %Y%M%D%041111%'
    """

  Scenario: Throw Exception if one of the fields "SECURITYCLIENT_ID" has blank value. Transactions data will not be transformed and published

    #Verify Exception in NTEL for SECURITYCLIENT_ID
    Then I expect value of column "EXP_REQ_SECURITYCLIENT_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_SECURITYCLIENT_ID FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '3')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields SECURITYCLIENT_ID is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "PORTFOLIO" has blank value. Transactions data will not be transformed and published
    #Verify Exception in NTET for PORTFOLIO
    Then I expect value of column "EXP_REQ_PORTFOLIO" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_PORTFOLIO FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '4')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, PORTFOLIO is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "EXT_ID1" has blank value. Transactions data will not be transformed and published
    #Verify Exception in NTEL for EXT_ID1
    Then I expect value of column "EXP_REQ_EXT_ID1" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_EXT_ID1 FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '5')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, EXT_ID1 is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "TRANSACTION" has blank value. Transactions data will not be transformed and published
    #Verify Exception in TRANSACTION
    Then I expect value of column "EXP_TRANSACTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_TRANSACTION FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '6')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, TRANSACTION is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "TRADE_DATE" has blank value. Transactions data will not be transformed and published
    #Verify Exception in TRADE_DATE
    Then I expect value of column "EXP_REQ_TRADE_DATE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_TRADE_DATE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '7')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, TRADE_DATE is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "EXECUTION_DATE" has blank value. Transactions data will not be transformed and published
    #Verify Exception in EXECUTION_DATE
    Then I expect value of column "EXP_REQ_EXECUTION_DATE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_EXECUTION_DATE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '8')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, EXECUTION_DATE is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "SETTLE_DATE" has blank value. Transactions data will not be transformed and published
    #Verify Exception in SETTLE_DATE
    Then I expect value of column "EXP_REQ_SETTLE_DATE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_SETTLE_DATE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '9')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, SETTLE_DATE is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "QUANTITY" has blank value. Transactions data will not be transformed and published
    #Verify Exception in QUANTITY
    Then I expect value of column "EXP_REQ_QUANTITY" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_QUANTITY FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '10')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, QUANTITY is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "TRD_CURRENCY" has blank value. Transactions data will not be transformed and published
    #Verify Exception in TRD_CURRENCY
    Then I expect value of column "EXP_REQ_TRD_CURRENCY" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_TRD_CURRENCY FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '11')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, TRD_CURRENCY is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "PRICE" has blank value. Transactions data will not be transformed and published
    #Verify Exception in PRICE
    Then I expect value of column "EXP_REQ_PRICE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_REQ_PRICE FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '12')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, PRICE is not present in the input record.'
    """

  Scenario: Throw Exception if more than one required fields have blank value. Single Exception is generated. Transactions data will not be transformed and published
    #Verify Single excpetion is generated when more than one required field is missing.
    Then I expect value of column "SINGLE_EXP_REQ_FLDS" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SINGLE_EXP_REQ_FLDS FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '13')
    AND MSG_SEVERITY_CDE = 40
    AND NOTFCN_STAT_TYP != 'CLOSED'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields SECURITYCLIENT_ID, EXT_ID1, SETTLE_DATE, TRD_CURRENCY, PRICE is not present in the input record.'
    """