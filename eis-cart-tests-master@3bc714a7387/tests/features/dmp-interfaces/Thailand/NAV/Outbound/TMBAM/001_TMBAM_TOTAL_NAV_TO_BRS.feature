# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03-JUL-2020     EISDEV-6526    TMBAM total NAV files to BRS - In-Memory translation
#                                https://jira.pruconnect.net/browse/EISDEV-6526
# 16-Aug-2020     EISDEV-6746    https://jira.pruconnect.net/browse/EISDEV-6746
#                                Logic: If the date is <T Business day, default it to T date by following Thai Holiday calender
#                                If the date is =T Date, then no change , T Date =File date
# ==================================================================================================
#Purpose : An additional attribute data_type need to be added in the file with value defaulted to ABOR_COMPL for all the records
#Functional Specification: https://collaborate.pruconnect.net/display/EISTT/Total+NAV%7CAladdin+BPP%7CTMBAM%2CTFUND
#eisdev_6833 : send an email notification to TMBAM when NAV VALUE is 0 for the portfolio

@gc_interface_nav
@dmp_regression_unittest
@eisdev_6526 @eisdev_6526_tmbam_totalnav @dmp_thailand_nav @dmp_thailand @eisdev_6746 @eisdev_6833
Feature: TMBAM Total NAV In-Memory translation process

  An additional attribute data_type need to be added in the file with value defaulted to ABOR_COMPL for all the records,
  This column uses in Compliance rules execution.

  EISDEV-6746
  DATE,PORTFOLIO,VALUE,INSTRUCTIONAL_HEADER
  08/13/2020,E01,75480419.57,      - Validate a T date scenario
  08/12/2020,I13,3597563320.61,    - 08/12/2020 is public holiday so it should modify in output file as T date 08/13/2020
  08/11/2020,I10,2141992747.05,    - Less then T-1 date so it should modify in output file as T date 08/13/2020
  08/09/2020,I08,22860518.44,      - Less then T-1 date so it should modify in output file as T date 08/13/2020
  07/18/2040,PR2,0.00,             - 07/18/2040 is future date NAV, it should not change anything

  EISDEV-6833 -  Log validation message for NAV VALUE is 0 for the portfolio followed by send an notification
  DATE,PORTFOLIO,VALUE,INSTRUCTIONAL_HEADER
  08/13/2020,I02,,           - Log validation message in NTEL as Net Asset Value is null for this portfolio: I02, Date:08/13/2020
  08/13/2020,I03,0,          - Log validation message in NTEL as Net Asset Value is 0 for this portfolio: I03, Date:08/13/2020
  08/13/2020,I05,0.0,        - Log validation message in NTEL as Net Asset Value is 0 for this portfolio: I05, Date:08/13/2020
  08/13/2020,I06,0.00,       - Log validation message in NTEL as Net Asset Value is 0 for this portfolio: I06, Date:08/13/2020
  08/13/2020,I07,.0,         - Log validation message in NTEL as Net Asset Value is 0 for this portfolio: I07, Date:08/13/2020
  08/13/2020,I14,.00,        - Log validation message in NTEL as Net Asset Value is 0 for this portfolio: I14, Date:08/13/2020

  Scenario: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/NAV/Outbound/TMBAM" to variable "testdata.path"
    And I assign "001_esi_input_TMBAM_netassetvalue_20200813.csv" to variable "INPUT_FILENAME"
    And I assign "esi_TMBAM_netassetvalue" to variable "RUNTIME_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/in/tmbam" to variable "PUBLISHING_DIR"
    And I assign "001_esi_TMBAM_netassetvalue_expected.csv" to variable "EXPECTED_FILENAME"

  Scenario: An additional column as data_type an default to ABOR_COMPL using GS In-Memory translation

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
      | MESSAGE_TYPE            | EITH_MT_TMBAM_TOAL_NAV                                                                                                                                                      |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}/tmbam                                                                                                                                               |
      | EMAIL_TO                | testautomation@eastspring.com                                                                                                                                               |
      | EMAIL_SUBJECT           | SANITY TEST TMBAM TOTAL NAV - Exception Details                                                                                                                             |
      | PUBLISH_LOAD_SUMMARY    | false                                                                                                                                                                       |
      | SUCCESS_ACTION          | DELETE                                                                                                                                                                      |
      | FILE_PATTERN            | ${INPUT_FILENAME}                                                                                                                                                           |
      | POST_EVENT_NAME         |                                                                                                                                                                             |
      | ATTACHMENT_FILENAME     |                                                                                                                                                                             |
      | HEADER                  | Please see the summary of the load below                                                                                                                                    |
      | FOOTER                  | DMP Team, Please do not reply to this mail.                                                                                                                                 |
      | FILE_LOAD_EVENT         | EIS_StandardFileTransformation                                                                                                                                              |
      | EXCEPTION_DETAILS_COUNT | 10                                                                                                                                                                          |
      | NOOFFILESINPARALLEL     | 1                                                                                                                                                                           |
      | DETAILS_HEADER          | Details                                                                                                                                                                     |
      | DETAILS_SQL             | SELECT REGEXP_REPLACE(CHAR_VAL_TXT,'Missing Data Exception:- User defined Error thrown! .','') CHAR_VAL_TXT FROM FT_V_DTL1 WHERE NOTFCN_STAT_TYP='OPEN' AND PRNT_JOB_ID = ? |
      | SUMMARY_HEADER          | Filename                                                                                                                                                                    |
      | SUMMARY_SQL             | SELECT REGEXP_REPLACE(FILENAME,'_org','') FILENAME FROM FT_V_SUM1 WHERE PRNT_JOB_ID = ?                                                                                     |


    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "11"
    And completed record count as "11"

  Scenario: Recon the output files
  Compare the output file from previous step and expected output result, if there is any exception then it creates exception file

    Given I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${RUNTIME_FILE_NAME}_${VAR_SYSDATE}.csv |

    When I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${RUNTIME_FILE_NAME}_${VAR_SYSDATE}.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${RUNTIME_FILE_NAME}_${VAR_SYSDATE}.csv |
      | ExpectedFile | ${testdata.path}/outfiles/expected/${EXPECTED_FILENAME}                   |

  Scenario: Validate NAV value equal to zero in NTEL Table

    Then I expect value of column "EXCEPTION_MSG2_CHECK" in the below SQL query equals to "7":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG2_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60001'
      AND ntel.CHAR_VAL_TXT LIKE 'Missing Data Exception:- User defined Error thrown! . Net Asset Value is %'
      """