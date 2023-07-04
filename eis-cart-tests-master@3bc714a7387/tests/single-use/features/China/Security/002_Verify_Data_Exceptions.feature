# =======================================================================================================
# Feature History
# TOM-4195 : Initial Version of feature file
# Technical Document : https://collaborate.intranet.asia/display/TOM/WFOE+-+Security#Test-testScenario
# EISDEV-5400: Modified RCRLBU connector to load GP & RCR files. Hence, the transformation is not required anymore
# =======================================================================================================

@dmp_wfoe @dmp_wfoe_security @dmp_wfoe_security_verify_exceptions @tom_4195
Feature: 002 | China-WFOE | Security | Verify In-Memory Data Exceptions

  Scenario: Throw Exception if "CLIENT_SEC_TYPE" has value other than the configured RCR Security Type. Security data will not be transformed and published

    Given I assign "002_esi_sc_security_verify_exceptions.csv" to variable "INPUT_FILENAME"
    And I assign "WFOEEISLINSTMT" to variable "OUTPUT_FILENAME"
    And I assign "001_002_WFOEEISLINSTMT_TEMPLATE.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/fundapps" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/single-use/China/Security" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${OUTPUT_FILENAME}* |

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform file
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EICN_MT_RCR_SECURITY"

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
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '7')
    AND MSG_SEVERITY_CDE = 40
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as incoming CLIENT_SEC_TYPE = Government Bond is not valid RCR - Security Type'
    """

  Scenario: Throw Exception if "MATURITY" has invalid date '20562441', Security data will not be transformed and published

    #Verify Exception in NTEL for INVALID_DATE : 20562441
    Then I expect value of column "EXP_INVALID_DATE_20562441" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_INVALID_DATE_20562441 FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '9')
    AND MSG_SEVERITY_CDE = 50
    AND PARM_VAL_TXT like '%Function %ReformatDateTime% Parameter Nr.: 1 Error: 20562441 Format String: %Y%M%D%'
    """

  Scenario: Throw Exception if "MATURITY" has invalid date '205608', Security data will not be transformed and published

    #Verify Exception in NTEL for INVALID_DATE : 205608
    Then I expect value of column "EXP_INVALID_DATE_205608" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXP_INVALID_DATE_205608 FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '10')
    AND MSG_SEVERITY_CDE = 50
    AND PARM_VAL_TXT like '%Function %ReformatDateTime% Parameter Nr.: 1 Error: 205608 Format String: %Y%M%D%'
    """

  Scenario: Throw Exception if one of the fields "CLIENT_ID" has blank value. Security data will not be transformed and published

    #Verify Exception in NTEL for CLIENT_ID
    Then I expect value of column "EXCEPTION_REQ_CLIENT_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_REQ_CLIENT_ID FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '2')
    AND MSG_SEVERITY_CDE = 40
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields CLIENT_ID is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "DESC_INSTMT" has blank value. Security data will not be transformed and published

    #Verify Exception in NTET for DESC_INSTMT
    Then I expect value of column "EXCEPTION_REQ_DESC_INSTMT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_REQ_DESC_INSTMT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '3')
    AND MSG_SEVERITY_CDE = 40
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, DESC_INSTMT is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "CURRENCY" has blank value. Security data will not be transformed and published

    #Verify Exception in NTEL for CURRENCY
    Then I expect value of column "EXCEPTION_REQ_CURRENCY" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_REQ_CURRENCY FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '4')
    AND MSG_SEVERITY_CDE = 40
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, CURRENCY is not present in the input record.'
    """

  Scenario: Throw Exception if one of the fields "ISSUER" has blank value. Security data will not be transformed and published
    #Verify Exception in ISSUER
    Then I expect value of column "EXCEPTION_REQ_ISSUER" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_REQ_ISSUER FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '5')
    AND MSG_SEVERITY_CDE = 40
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields, ISSUER is not present in the input record.'
    """

  Scenario: Throw Exception if all fields "CLIENT_ID, DESC_INSTMT, CURRENCY, ISSUER" have blank value. Single Exception is generated
    #Verify Single excpetion is generated when more than one required field is missing.
    Then I expect value of column "EXCEPTION_ALL_REQ_FIELDS" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_ALL_REQ_FIELDS FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '6')
    AND MSG_SEVERITY_CDE = 40
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields CLIENT_ID, DESC_INSTMT, CURRENCY, ISSUER is not present in the input record.'
    """