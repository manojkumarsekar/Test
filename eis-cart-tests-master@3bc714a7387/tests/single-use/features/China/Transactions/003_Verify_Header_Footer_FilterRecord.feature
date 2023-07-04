# =======================================================================================================
# Feature History
# TOM-4195 : Initial Version of feature file
# Technical Document : https://collaborate.intranet.asia/display/TOM/WFOE+-+Transactions#Test-testScenario
# EISDEV-5400: Modified RCRLBU connector to load GP & RCR files. Hence, the transformation is not required anymore
# =======================================================================================================

@dmp_wfoe @dmp_wfoe_transactions @dmp_wfoe_transactions_verify_hf_filter @tom_4205
Feature: 003 | China-WFOE | Transactions | Verify Header and Footer in case First and Last record in Input file is Filtered Record

  Scenario: Verify Header and Footer in case First and Last record in Input file is Filtered Record

    Given I assign "003_esi_sc_transactions_verify_hf_filter.csv" to variable "INPUT_FILENAME"
    And I assign "WFOEEISLTRANSN" to variable "OUTPUT_FILENAME"
    And I assign "003_004_005_WFOEEISLTRANSN_TEMPLATE.csv" to variable "MASTER_FILENAME"
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

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    And I rename file "${PUBLISHING_DIR}/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" as "${PUBLISHING_DIR}/003_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | 003_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    #Reconcile output file with the standard template file. Failed Records are not published
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/003_${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${MASTER_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file