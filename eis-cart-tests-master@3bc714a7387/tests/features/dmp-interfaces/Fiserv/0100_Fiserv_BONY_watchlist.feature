# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 20/07/2020      EISDEV-6432 Fiserv - File publishing for BONY (https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISFISERV&title=EISG+-+BONY)
# 02/09/2020      EISDEV-6743 Amend test file to use comma separated values and enclose all values with quotations
# ===================================================================================================================================================================================
# FS : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISFISERV&title=EISG+-+BONY

@gc_interface_fiserv
@dmp_regression_unittest
@eisdev_6432
@eisdev_6743
Feature: 001 | Fiserv | BONY Watchlist | Verify BONY file transformed to FISERV format

	As a user I expect a BONY AML watchlist file to be transformed into a FISERV formatted file

	Test Scenarios
	===================================================================================================================================================================================
	FILE               | CODE  | Expectation   | Fullname1     | LastName1 | FullAddress1
	===================================================================================================================================================================================
	bony_watchlist.txt | 20009 | Transformed   | Joe Bloggs    |           | 60 Lorong J Telok Kurau,Singapore 425837
	bony_watchlist.txt | 20010 | Transformed   | Mr John Smith | Smith     | 600 Sembawang Road,#01-23,Singapore 757707
	bony_watchlist.txt | 20011 | Filtered      |               |           |

  Scenario: Transform BONY watchlist to FISERV format

    Given I assign "tests/test-data/dmp-interfaces/Fiserv" to variable "testdata.path"
    And I assign "bony_watchlist.txt" to variable "INPUT_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "WLF_MONTHLY_EISG_BNY_${VAR_SYSDATE}.txt" to variable "TRANSFORMED_FILE_NAME"
    And I assign "/dmp/out/fiserv" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "TRANSFORM_WF"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME} |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/bony":
      | ${INPUT_FILENAME} |

    And I process the workflow template file "${TRANSFORM_WF}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BONY_FISERV_WATCHLIST   |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}/bony   |
      | EMAIL_TO                | testautomation@eastspring.com  |
      | EMAIL_SUBJECT           | ERRORS FOUND IN TRANSFORM      |
      | PUBLISH_LOAD_SUMMARY    | false                          |
      | SUCCESS_ACTION          | DELETE                         |
      | FILE_PATTERN            | ${INPUT_FILENAME}              |
      | FILE_LOAD_EVENT         | EIS_StandardFileTransformation |
      | NOOFFILESINPARALLEL     | 1                              |
      | EXCEPTION_DETAILS_COUNT | 10                             |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRANSFORMED_FILE_NAME} |
      
	Scenario: Compare BONY FISERV file against expected output
	
	Given I exclude below column indices from CSV file while doing reconciliations
    | 1 |
    
	Then I expect reconciliation should be successful between given CSV files
    | ActualFile   | ${testdata.path}/outfiles/runtime/${TRANSFORMED_FILE_NAME}           |
    | ExpectedFile | ${testdata.path}/outfiles/expected/WLF_MONTHLY_EISG_BNY_expected.txt |
