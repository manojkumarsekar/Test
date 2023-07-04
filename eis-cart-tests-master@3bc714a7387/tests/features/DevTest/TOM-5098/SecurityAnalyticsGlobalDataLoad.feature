# ==============================================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 09/09/2019      TOM-5098    First Version
# This feature file is to test, in-memory-translation of Security Analytics Global file from BRS
# FS: https://collaborate.intranet.asia/display/TOM/Outbound+AHHLDU+index+level+return+to+Rimes+for+AHHLDM+calculation?src=jira
# ==============================================================================================================================

@gc_interface_securities
@dmp_regression_unittest
@tom_5098 @analytics_data
Feature: SecurityAnalyticsGlobal In-memory Translation

  Scenario: Translating Security Analytics Global file from BRS into RIMES expected format

    Given I assign "esi_security_analytics_global_20190905.xml" to variable "INPUT_FILENAME"
    And I assign "esi_rimes_analytics_pnl" to variable "OUTPUT_FILENAME"
    And I assign "esi_rimes_analytics_pnl_template.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/DevTest/TOM-5098" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform BNP Performance Returns file to BRS format
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_SEC_ANALYTICS_GLOBAL"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    #Reconcile output file with the standard template file
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/reference/${MASTER_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles//runtime/exceptions_${recon.timestamp}.csv" file
