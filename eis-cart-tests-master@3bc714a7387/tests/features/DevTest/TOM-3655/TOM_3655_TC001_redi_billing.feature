# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 29/01/2019      TOM-3655    First Version
# =================================================================================================

#No regression tag observed. Hence, modular tag (Ex: gc_interface or dw_interface) has not given.
@tom_3655 @redi_billing @month_end_reporting @data_dumps
Feature: REDI Billing

  Publish REDI Billing

  Scenario: Assign Variables
    And I assign "tests/test-data/DevTest/TOM-3655" to variable "testdata.path"
    And I assign "redi_billing" to variable "REDI_BILLING_PUBLISHING_FILENAME"
    And I assign "/dmp/out/eis/redi2" to variable "PUBLISHING_DIR"

  Scenario: Set max polling time variable
    #By default Publishing job polling time is 300sec. Since these are testing jobs, we don't want to wait 300sec in case of failures
    #so setting to 600sec and removing this variable at the end
    Given I assign "600" to variable "workflow.max.polling.time"

  Scenario: Publish REDI Billing Report for data validation

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${REDI_BILLING_PUBLISHING_FILENAME}.csv |

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                 |
      | CONVERT_TO_EXCEL    | false                                                                                                  |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                      |
      | PUBLISHING_FILENAME | ${REDI_BILLING_PUBLISHING_FILENAME}.csv                                                                |
      | THREAD_COUNT        | 1                                                                                                      |
      | SQL_ID              | SELECT DISTINCT posn_sok id FROM ft_v_rpt1_redi_billing WHERE me_date = TO_DATE('20181130','yyyymmdd') |
      | SQL_PUBLISH         | SELECT posn_sok id, flow_data FROM ft_v_rpt1_redi_billing                                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${REDI_BILLING_PUBLISHING_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${REDI_BILLING_PUBLISHING_FILENAME}.csv |

    # Validation: Reconcile Data with template
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${REDI_BILLING_PUBLISHING_FILENAME}.csv" and reference CSV file "${testdata.path}/outfiles/expected/${REDI_BILLING_PUBLISHING_FILENAME}.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

    # Validation: There should not be any duplicate positions in the previous 3 months.
    Then I expect value of column "DUPLICATE_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS DUPLICATE_COUNT
    FROM (SELECT posn_sok
      FROM gs_dw.ft_v_rpt1_redi_billing
      WHERE me_date>= ADD_MONTHS(TRUNC(SYSDATE, 'MON'), -2) - 1
      GROUP BY posn_sok HAVING COUNT(*) > 1)
    """

  Scenario: Cleanup max polling time variable

    Then I remove variable "workflow.max.polling.time" from memory


