#Feature History
#TOM-3768: Moved the feature file from as per new folder structure. Updated Feature Description

@dmp_smoke @file_transfer_wf @tom_3768 @pvt @dmp_gs_upgrade
Feature: GC Smoke | Orchestrator | ESI | Misc | File Transfer

  Scenario: Verify Execution of Workflow for .csv file

    Given I assign "test_FileTransfer.csv" to variable "INPUT_FILENAME"
    Given I assign "tests/test-data/dmp-gs/gswf/EIS_FileTransfer" to variable "TESTDATA_PATH"

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.archive.path}" if exists:
      | ${INPUT_FILENAME} |
    When I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process file transfer with below parameters and wait for the job to be completed
      | FILE_PATH         | ${dmp.ssh.inbound.path} |
      | CONFIG_SOURCE     |                         |
      | FILE_PATTERN      | ${INPUT_FILENAME}       |
      | ARCHIVE_FILE_PATH | ${dmp.ssh.archive.path} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS JBLG_ROW_COUNT FROM FT_T_JBLG
        WHERE JOB_ID = '${JOB_ID}'
        AND JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}%'
      """

    When I send a web service request using an xml file "testout/dmp-interfaces/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${dmp.ssh.archive.path}" after processing:
      | ${INPUT_FILENAME} |

  Scenario: TC_WF_2 - Test the workflow "EIS_FileTransfer" on "FileTransfer.csv" file with Incorrect Pattern

    When I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process file transfer with below parameters and wait for the job to be completed
      | FILE_PATH         | ${dmp.ssh.inbound.path} |
      | CONFIG_SOURCE     |                         |
      | FILE_PATTERN      | INCORRECT_PATTERN*.csv  |
      | ARCHIVE_FILE_PATH | ${dmp.ssh.archive.path} |


    When I send a web service request using an xml file "testout/dmp-interfaces/asyncResponse.xml" and save the response to file "testout/evidence/gswf/resp/GetEventResultResponse.xml"

    Then I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/evidence/gswf/resp/GetEventResultResponse.xml" with tagName "failed" should be "false"

    And I expect below files to be retained to the host "dmp.ssh.inbound" into folder "${dmp.ssh.inbound.path}" after processing:
      | ${INPUT_FILENAME} |

