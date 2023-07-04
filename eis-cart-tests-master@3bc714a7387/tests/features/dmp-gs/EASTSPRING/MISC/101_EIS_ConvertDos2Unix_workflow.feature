#Feature History
#TOM-3768: Moved the feature file from as per new folder structure. Updated Feature Description

@dmp_smoke @dos2unix_wf @tom_3472 @tom_3768 @pvt
Feature: GC Smoke | Orchestrator | ESI | Misc | Convert Dos2Unix

  #Background
  #Currently the Drifted Benchmark Output Interface Files being sent to BNP in Windows format. Eg.: <CR><LF>
  #This is creating an issue at BNP end as they can consume only UNIX file format. i.e. <LF>.

  #This testcase validate the Drifted BMK file format
  #Below Steps are followed to validate this testing

  #1. Copy the file(s) to the DMP server
  #2. Run the workflow and validate the Unix format of the file by recognising <CR> count.

  Scenario: Verify Execution of Workflow

  Copy the source file from source and place in DMP server folder.

    Given I assign "test_esi_bnp_drifted_bmk_weights.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3472" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    #File gets converted to UNIX format in the same source location.
    And I process ConvertDos2Unix workflow with below parameters and wait for the job to be completed
      | SOURCE_PATH  | ${dmp.ssh.inbound.path} |
      | FILE_PATTERN | ${INPUT_FILENAME}       |

    Then I expect file "${dmp.ssh.inbound.path}\${INPUT_FILENAME}" is in Unix format in the named host "dmp.ssh.inbound"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}" if exists:
      | ${INPUT_FILENAME} |