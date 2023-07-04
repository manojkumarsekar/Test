# =================================================================================================
# Date            JIRA            Comments
# ============    ========        ========
# 23/01/2019      EISDEV-5490     MONTHLY POSITION M&G REPORT
# 14/04/2021      EISDEV-7212     Recon failure fix
#
# Requirement link: https://collaborate.pruconnect.net/pages/viewpage.action?pageId=39825064
# =================================================================================================

@dw_interface_positions @dw_interface_reports
@dmp_dw_regression
@eisdev_5490 @eisdev_7212
Feature: Verify month end Position file for MNG portfolios.

  As part of Dev Ticket EISDEV-5490, a separate Month End Position file for MNG funds should be created.
  This feature is designed to check whether the new Month End Position file for MNG funds contains only positions belongs to Eastspring managed  M&G funds

  Scenario: Assign Variables and Set up Configuration
    And I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Position" to variable "TESTDATA_PATH"
    And I assign "002_ESIPME_POS_MNG.out" to variable "INPUT_FILENAME"
    And I assign "/dmp/out/eis/general" to variable "PUBLISHING_DIR"
    And I assign "month_end_positions_MNG.csv" to variable "PUBLISHING_FILENAME"
    And I assign "month_end_positions_MNG_Reference.csv" to variable "REFERENCE_FILE_NAME"

    And I execute below query to "ensure mng fund exists to generate positions on 20200229"
    """
    ${TESTDATA_PATH}/sql/Insert_MNG_Fund.sql;
    """

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I execute below query to "clear the positions on 20200229"
    """
    delete from FT_W_POSN where trunc(as_of_tms) = trunc(TO_DATE('20200229','yyyymmdd'));
    commit
    """

    Then I expect value of column "record_count" in the below SQL query equals to "0":
    """
    SELECT count(1) AS record_count
    FROM ft_v_rpt1_meds_positions
    WHERE me_date = TO_DATE('20200229','yyyymmdd')
    """

  Scenario: Loading Positions Data with MNG and Non MNG funds to ensure only MNG positions comes in the new report

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    Given I process "${TESTDATA_PATH}/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS |
      | BUSINESS_FEED |                     |

    When I assign "300" to variable "workflow.max.polling.time"

    Then I expect value of column "record_count" in the below SQL query equals to "12":
    """
    SELECT count(1) AS record_count
    FROM ft_v_rpt1_meds_positions
    WHERE me_date = TO_DATE('20200229','yyyymmdd')
    """

  Scenario: Publish MNG Report

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                                                                       |
      | CONVERT_TO_EXCEL    | false                                                                                                                                                        |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                                                                            |
      | PUBLISHING_FILENAME | ${PUBLISHING_FILENAME}                                                                                                                                       |
      | THREAD_COUNT        | 1                                                                                                                                                            |
      | SQL_ID              | SELECT DISTINCT posn_sok id FROM ft_v_rpt1_meds_positions WHERE me_date = TO_DATE('20200229','yyyymmdd') AND acct_id IN (SELECT acct_id FROM ft_v_mng_funds) |
      | SQL_PUBLISH         | SELECT posn_sok id, flow_data FROM ft_v_rpt1_meds_positions                                                                                                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILENAME} |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/expected/${REFERENCE_FILE_NAME} |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILENAME}  |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory