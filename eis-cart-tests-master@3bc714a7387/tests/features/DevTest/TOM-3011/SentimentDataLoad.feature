# ==============================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 30/01/2019      TOM-3011    First Version
# This feature file is to test im memory translation of sentiment file from BAML
# ==============================================================================

@gc_interface_sentiment
@dmp_regression_unittest
@tom_3011
Feature: Sentiment In-memory Translation

  Scenario: Translating sentiment file

    Given I assign "JapanContendersRankSentiment.csv" to variable "INPUT_FILENAME"
    And I assign "galileo_ESISG_Japan_sentiment" to variable "OUTPUT_FILENAME"
    And I assign "galileo_ESISG_Japan_sentiment_template.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/DevTest/TOM-3011" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform BNP Performance Returns file to BRS format
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BAML_SENTIMENT"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    #Reconcile output file with the standard template file
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/reference/${MASTER_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file
