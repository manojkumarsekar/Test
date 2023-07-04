#https://jira.intranet.asia/browse/TOM-5059
#https://collaborate.intranet.asia/display/TOM/FI+Research+Issuer+Aggregation+Logic

@gc_interface_issuer @gc_interface_ratings
@dmp_regression_integrationtest
@tom_5059
Feature: CI | Issuer Rating Aggregation | Verify Inbound and Outbound Issuers rating from SNP, Moodys and Fitch

  This feature file is to test Inbound and Outbound of Issuer Rating Aggregation
  Here we get rating codes from agencies like SNP, Moodys and Fitch (AGY - 1,2,3,131,123,133)
  In INBOUND, we will set up these rating codes in dmp in FIRT table - if required domain (RTVL) is missing,
  exception will be raised to mo.data.support.sg@eastspring.com
  ERVL domains should be provided to store score of each rating code
  In OUTBOUND, we will fetch rating code and score from dmp and compare it internally and publish the rating
  code which has higher score - comparision will be done between [1-131], [2-123] and [3-133]

  Scenario: Assign Variables
    Given I assign "tests/test-data/DevTest/TOM-5059" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "200" to variable "workflow.max.polling.time"
    And I assign "Issuer_Rating_Aggregation" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/8b_ratings" to variable "PUBLISHING_DIRECTORY"

  Scenario: Clear old Issuer Data

    Given I execute below query
    """
    ${TESTDATA_PATH}/sql/Clear_FINS_FIRT.sql
    """

  Scenario: Load Issuer Data - 3 records

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TOM_5059_Issuer.xml |

    And I process Load files and publish exceptions with below parameters and wait for the job to be completed
      | ATTACHMENT_FILENAME     | ExceptionDetails.xlsx                                                                                                                                                                                                                                                                                                                     |
      | DETAILS_SQL             | SELECT FILENAME, MAIN_ENTITY_ID, MAIN_ENTITY_ID_CTXT_TYP, ERROR_LEVEL, EXCP_TYP, NOTFCN_ID, CHAR_VAL_TXT, NOTFCN_OCCUR_CNT FROM FT_V_DTL1 WHERE PRNT_JOB_ID = ? AND NOTFCN_STAT_TYP='OPEN' AND NOTFCN_ID = '21' AND SOURCE_ID LIKE '%GS_GC%'                                                                                              |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}                                                                                                                                                                                                                                                                                                                   |
      | EMAIL_TO                | swapnali.jadhav@eastspring.com                                                                                                                                                                                                                                                                                                            |
      | FOOTER                  | DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited |
      | HEADER                  | Hi Team                                                                                                                                                                                                                                                                                                                                   |
      | EMAIL_SUBJECT           | TOM_5059_Exceptions_Test_Mail                                                                                                                                                                                                                                                                                                             |
      | FILE_LOAD_EVENT         | StandardFileLoad                                                                                                                                                                                                                                                                                                                          |
      | NOOFFILESINPARALLEL     | 2                                                                                                                                                                                                                                                                                                                                         |
      | MESSAGE_TYPE            | EIS_MT_BRS_ISSUER                                                                                                                                                                                                                                                                                                                         |
      | PUBLISH_LOAD_SUMMARY    | false                                                                                                                                                                                                                                                                                                                                     |
      | SUCCESS_ACTION          | LEAVE                                                                                                                                                                                                                                                                                                                                     |
      | EXCEPTION_DETAILS_COUNT | 10                                                                                                                                                                                                                                                                                                                                        |
      | FILE_PATTERN            | TOM_5059_Issuer.xml                                                                                                                                                                                                                                                                                                                       |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Verification of failures due to missing rating code in dmp

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '21'
      AND ntel.source_id like '%GS_GC%'
      AND ntel.CHAR_VAL_TXT LIKE '%Rating value%SWAP1%for Rating Set%Fitch (Primary)%not found in table%'
      """

    Then I expect value of column "FIRT_COUNT" in the below SQL query equals to "16":
      """
      SELECT COUNT(*) AS FIRT_COUNT
      FROM FT_T_FIRT WHERE INST_MNEM IN
      (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('000375','001625','00038A')
      AND FINS_ID_CTXT_TYP ='BRSISSRID') and end_tms is null
      """

  Scenario: Publish File

   #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_ISSUER_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify issuer rating outbound file

    Then I expect each record in file "${TESTDATA_PATH}/outfiles/reference/Issuer_Rating_Aggregation_reference.csv" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_Exceptions.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory