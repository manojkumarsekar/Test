# =======================================================================================================
# Feature History
# TOM-4206 : Initial Version of feature file
# Technical Document : https://collaborate.intranet.asia/display/TOM/WFOE+-+Positions#Test-testScenario
# EISDEV-5400: Modified RCRLBU connector to load GP & RCR files. Hence, the transformation is not required anymore
# =======================================================================================================

@dmp_wfoe @dmp_wfoe_positions @dmp_wfoe_positions_verify_data_transformation @tom_4206
Feature: 001 | China-WFOE | Positions | Verify In-Memory Data Transformation

  Scenario: Verify In-Memory Data Transformation of CITICs Security file into RCR Positions File

    Given I assign "001_esi_sc_positions_verify_data.csv" to variable "INPUT_FILENAME"
    And I assign "WFOEEISLPOSITN" to variable "OUTPUT_FILENAME"
    And I assign "001_002_WFOEEISLPOSITN_TEMPLATE.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/fundapps" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/single-use/China/Positions" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${OUTPUT_FILENAME}* |

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform File
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EICN_MT_RCR_POSITIONS"

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

    And I rename file "${PUBLISHING_DIR}/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" as "${PUBLISHING_DIR}/001_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | 001_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    #Reconcile output file with the standard template file
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/001_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${MASTER_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: Verify FOOTER record is appended in input file

    Then I expect value of column "FOOTER_RECORD" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FOOTER_RECORD FROM FT_T_TRID
    WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '4'
    AND MAIN_ENTITY_ID = 'FOOTER'
    """

  Scenario: Verify Filter Record if CLIENT_SEC_TYPE is blank

    Then I expect value of column "FILTER_601288" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FILTER_601288 FROM FT_T_TRID
    WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM = '2'
    AND TRN_USR_STAT_TYP = 'FILTERED'
    """