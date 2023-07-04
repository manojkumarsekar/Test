#Feature History
#TOM-3768: Moved the feature file from as per new folder structure. Updated Feature Description
#EISDEV-6246: added scenario to verify null cell type conversion

@dmp_smoke @convert_xlsx_to_csv_wf @tom_3768 @pvt @dmp_gs_upgrade @eisdev_6246 @exceltocsv
Feature: GC Smoke | Orchestrator | ESI | Load | Convert XLSX to CSV and Load

  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Background:
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.archive.path}" if exists:
      | Snapshot_ConvertXLSXtoCSV_Test.xlsx |
      | Snapshot_ConvertXLSXtoCSV_Test.csv  |

    And I assign "tests/test-data/dmp-gs/gswf/EIS_ConvertXlsxToCsv" to variable "TESTDATA_PATH"

  Scenario: TC_WF_1 - Test the workflow "EIS_ConvertXLSXtoCSVandLoad" on "Snapshot_ConvertXLSXtoCSV_Test.xlsx" file

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BRS_REBAL_BENCHMARK"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "FILEPATTERN" to "Snapshot*XLSX*CSV*.xlsx"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.archive.path}"
    And I set the workflow template parameter "SUCCESS_ACTION" to "MOVE"

    When I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | Snapshot_ConvertXLSXtoCSV_Test.xlsx |

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be archived to the host "dmp.ssh.inbound" into folder "${dmp.ssh.archive.path}" after processing:
      | Snapshot_ConvertXLSXtoCSV_Test.xlsx |
      | Snapshot_ConvertXLSXtoCSV_Test.csv  |

  Scenario: TC_WF_2 - Test the workflow "EIS_ConvertXLSXtoCSVandLoad" on "Snapshot_ConvertXLSXtoCSV_Test.xlsx" file with Incorrect Pattern

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BRS_REBAL_BENCHMARK"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "FILEPATTERN" to "INCORRECT_PATTERN*.csv"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.archive.path}"
    And I set the workflow template parameter "SUCCESS_ACTION" to "MOVE"

    When I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | Snapshot_ConvertXLSXtoCSV_Test.xlsx |

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
     """
     SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
     """

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be retained to the host "dmp.ssh.inbound" into folder "${dmp.ssh.inbound.path}" after processing:
      | Snapshot_ConvertXLSXtoCSV_Test.xlsx |


  Scenario: TC_WF_3 - Test the workflow "EIS_ConvertXLSXtoCSVandLoad" with blank cell type

    And I assign "Snapshot_GMP_ASPLUT_20200302_1117297.xlsx" to variable "INPUTFILE_XLSX"
    And I assign "Snapshot_GMP_ASPLUT_20200302_1117297.csv" to variable "CONVERTED_FILE_CSV"

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.archive.path}" if exists:
      | ${INPUTFILE_XLSX} |
      | ${CONVERTED_FILE_CSV}  |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIS_BF_BRS_REBAL_BENCHMARK"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUTFILE_XLSX}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.archive.path}"
    And I set the workflow template parameter "SUCCESS_ACTION" to "MOVE"

    When I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_XLSX} |

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    When I send a web service request using an xml file "testout/evidence/gswf/resp/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be archived to the host "dmp.ssh.inbound" into folder "${dmp.ssh.archive.path}" after processing:
      | ${INPUTFILE_XLSX} |
      | ${CONVERTED_FILE_CSV}  |

    Then I copy files below from remote folder "${dmp.ssh.archive.path}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${CONVERTED_FILE_CSV} |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${CONVERTED_FILE_CSV}" and reference CSV file "${TESTDATA_PATH}/outfiles/template/${CONVERTED_FILE_CSV}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_1_exceptions_${recon.timestamp}.csv" file
    