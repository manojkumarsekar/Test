# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 16-Aug-2020     EISDEV-6746    https://jira.pruconnect.net/browse/EISDEV-6746
#                                Logic: If the date is <T-1 Business day, default it to T-1 date by following Thai Holiday calender
#                                If the date is =T Date, then no change , T Date =File date
# ==================================================================================================

@gc_interface_nav
@dmp_regression_unittest
@eisdev_6746 @eisdev_6746_tmb_totalnav @dmp_thailand_nav @dmp_thailand
Feature: TMB Total NAV In-Memory translation process

  Logic: If the date is <T Business day, default it to T date by following Thai Holiday calender
  If the date is =T Date, then no change , T Date =File date

  Input file
  DATE,PORTFOLIO, VALUE ,DATA_SOURCE,CURRENCY,DATATYPE
  20200813,D14,58352644.38,TMBBK,THB,ABOR_COMPL        - Validate a T date scenario
  20200812,P01I16,605166722.6,TMBBK,THB,ABOR_COMPL     - 20200512 is public holiday so it should modify in output file as T date 20200813
  20200811,LP2030,611766.44,TMBBK,THB,ABOR_COMPL       - Less then T-1 date so it should modify in output file as T date 20200813
  20200809,P01I13,64222589.26,TMBBK,THB,ABOR_COMPL     - Less then T-1 date so it should modify in output file as T date 20200813
  20400806,P01I18,4011088.08,TMBBK,THB,ABOR_COMPL      - 20400806 is future date NAV, it should not change anything

  Scenario: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/NAV/Outbound/TMBAM" to variable "testdata.path"
    And I assign "002_esi_input_TMB_netassetvalue_20200814.csv" to variable "INPUT_FILENAME"
    And I assign "esi_TMB_netassetvalue" to variable "RUNTIME_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/in/tmbam" to variable "PUBLISHING_DIR"
    And I assign "002_esi_TMB_netassetvalue_expected.csv" to variable "EXPECTED_FILENAME"

  Scenario: If the date is less then T Business day, default it to T date by following Thai Holiday calender using GS In-Memory translation

    #Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${RUNTIME_FILE_NAME}_*.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/tmbam" if exists:
      | ${INPUT_FILENAME} |

    #Copy the input file
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/tmbam":
      | ${INPUT_FILENAME} |

    #Call the workflow
    And I process Load files and publish exceptions with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EITH_MT_TMB_TOAL_NAV                                     |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}/tmbam                            |
      | EMAIL_TO                | testautomation@eastspring.com                            |
      | EMAIL_SUBJECT           | SANITY TEST TMB TOTAL NAV - in-memory translation failed |
      | PUBLISH_LOAD_SUMMARY    | false                                                    |
      | SUCCESS_ACTION          | DELETE                                                   |
      | FILE_PATTERN            | ${INPUT_FILENAME}                                        |
      | POST_EVENT_NAME         |                                                          |
      | ATTACHMENT_FILENAME     |                                                          |
      | HEADER                  | Please see the summary of the load below                 |
      | FOOTER                  | DMP Team, Please do not reply to this mail.              |
      | FILE_LOAD_EVENT         | EIS_StandardFileTransformation                           |
      | EXCEPTION_DETAILS_COUNT | 10                                                       |
      | NOOFFILESINPARALLEL     | 1                                                        |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "5"
    And completed record count as "5"

  Scenario: Recon the output files
  Compare the output file from previous step and expected output result, if there is any exception then it creates exception file

    Given I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${RUNTIME_FILE_NAME}_${VAR_SYSDATE}.csv |

    When I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${RUNTIME_FILE_NAME}_${VAR_SYSDATE}.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${RUNTIME_FILE_NAME}_${VAR_SYSDATE}.csv |
      | ExpectedFile | ${testdata.path}/outfiles/expected/${EXPECTED_FILENAME}                   |