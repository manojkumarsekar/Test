# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 04-DEC-2019     EISDEV-5361    BRS Daily user Feed file to IAMPru - In-Memory tranlsation
#                                https://jira.pruconnect.net/browse/EISDEV-5361
# ==================================================================================================
#Requirement : IAMPru required Aladdin users information on daily basis to keep track of Aladdin access

@gc_interface_user_group
@dmp_regression_unittest
@eisdev_5361 @eisdev_5434 @eisdev_7252
Feature: Converts the usergroup XML file into CSV using the GS in-Memory translation process

  BRS will send the user details as part of R3.IN-SC02 BRS-DMP 'User Group' interface(Filename : esi_users_groups_yyyymmdd.xml)
  convert this format from .xml to .csv and filter for only "eastspring.com" users using the email column. Exclude all other users.
  Save the new file as EISG_Aladdin_account*.csv

  Scenario: Transform user group file from XML to CSV format
  Verify the transform usergroup XML into CSV format using the Goldensource in-Memory translation

    Given I assign "tests/test-data/DevTest/EISDEV-5361" to variable "testdata.path"
    And I assign "esi_users_groups_20191127.xml" to variable "INPUT_FILENAME"
    And I assign "EISG_Aladdin_account" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/iampru" to variable "PUBLISHING_DIR"
    And I assign "EISG_Aladdin_account.csv" to variable "TEMPLATE_FILENAME"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "ORDER_WORKFLOW"

    #Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/brs/eod" if exists:
      | ${INPUT_FILENAME} |

    #Copy the input file
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/brs/eod":
      | ${INPUT_FILENAME} |

    #Call the workflow
    And I process Load files and publish exceptions with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BRS_IAMPRU_USER_GROUP                                 |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}/brs/eod                              |
      | EMAIL_TO                | testautomation@eastspring.com                                |
      | EMAIL_SUBJECT           | SANITY TEST User Group - Global in-memory translation failed |
      | PUBLISH_LOAD_SUMMARY    | false                                                        |
      | SUCCESS_ACTION          | DELETE                                                       |
      | FILE_PATTERN            | ${INPUT_FILENAME}                                            |
      | POST_EVENT_NAME         |                                                              |
      | ATTACHMENT_FILENAME     |                                                              |
      | HEADER                  | Please see the summary of the load below                     |
      | FOOTER                  | DMP Team, Please do not reply to this mail.                  |
      | FILE_LOAD_EVENT         | EIS_StandardFileTransformation                               |
      | EXCEPTION_DETAILS_COUNT | 10                                                           |
      | NOOFFILESINPARALLEL     | 1                                                            |

     #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "9"
    And completed record count as "9"

  Scenario: Validate the output files
  Compare the output file from previous step and expected output result, if there is any exception then it creates exception file

    Given I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.csv |

    When I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.csv |

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/expected/${TEMPLATE_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

