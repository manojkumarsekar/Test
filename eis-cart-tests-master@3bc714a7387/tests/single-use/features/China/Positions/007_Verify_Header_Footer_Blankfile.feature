# =======================================================================================================
# Feature History
# TOM-4206 : Initial Version of feature file
# Technical Document : https://collaborate.intranet.asia/display/TOM/WFOE+-+Positions#Test-testScenario
# EISDEV-5400: Modified RCRLBU connector to load GP & RCR files. Hence, the transformation is not required anymore
# =======================================================================================================

@dmp_wfoe @dmp_wfoe_positions @dmp_wfoe_positions_verify_hf_0rec @tom_4206
Feature: 007 | China-WFOE | Positions | Verify blank file is not generated in case no records in file to process

  Scenario: Verify blank file is not generated in case no records in file to process

    Given I assign "007_esi_sc_positions_verify_hf_0rec.csv" to variable "INPUT_FILENAME"
    And I assign "WFOEEISLPOSITN" to variable "OUTPUT_FILENAME"
    And I assign "006_007_WFOEEISLPOSITN_TEMPLATE.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/fundapps" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/single-use/China/Positions" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${OUTPUT_FILENAME}* |

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform file
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EICN_MT_RCR_POSITIONS"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |