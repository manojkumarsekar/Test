# =================================================================================
# Date            JIRA           Comments
# ============    ===========    ========
# 27/03/2020      EISDEV-6162    Move Netflows publishing to DW - this feature file replaces GC tests 001 through 008
# 06/05/2020      EISDEV-5453    Amend steps for new approach of storing cross rates in ft_t_wfxr
# 07/06/2020      EISDEV-6474    Use two stored procedures to refresh FX rates and then MView
# 05/01/2021      EISDEV-6626    Added index on WTRD and tweaked daily cross rate view for better performance
# Requirement https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOM&title=FIN-01+-+Net+Flows+legacy+system
# =================================================================================

@dw_interface_netflows @dw_interface_transactions
@dmp_dw_regression
@eisdev_6162 @eisdev_5453 @eisdev_6474 @002_netflows_dw_fx_conv @eisdev_7384
Feature: 002 | Netflows | Verify FX conversions

  =======================================================================================================================================================
  The test data for the original features 001 to 005 came from production data in Sept 2018, and as such so did the expected output.
  The challenge faced with bringing this into the DW was that the materialised views for exchange rates only refreshes over the past 90 days.
  To meet that challenge we copy the 10 transactions required for these 5 tests into the month following today (SYSDATE), along with exchange rates and accounts.

  001 Portfolio currency USD; Issue currency USD; trade IDs C204743A and C238004A
  002 Portfolio currency SGD; Issue currency SGD; trade IDs C239668A and C245924A
  003 Portfolio currency HKD; Issue currency USD; trade IDs C206612A and C206600A
  004 Portfolio currency HKD; Issue currency HKD; trade IDs C215836A and C206597A
  005 Portfolio currency JPY; Issue currency SGD; trade IDs C232595A and C232659A

  The original tests 006 to 008 checked that the Netflows report used BNP currency code rather than DMP currency code. This has been included below with
  the update of ALJPDJ account portfolio currency from JPY to SGD (reset afterwards). The exchange rates used would be different and reconciliation fail if SGD was used.
  =======================================================================================================================================================

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: TC_1: Setup input and expected output files from templates

    #Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Netflows" to variable "testdata.path"
    And I assign "/dmp/out/eis/netflows" to variable "PUBLISHING_DIRECTORY"
    And I assign "002_Netflows_DW" to variable "PUBLISHING_FILE_NAME"
    And I assign "002_netflows_input_BNP_TRN_template.out" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "002_netflows_input_BNP_TRN.out" to variable "INPUT_FILENAME"
    And I assign "002_netflows_DW_expected_output.csv" to variable "EXPECTED_OUTPUT_FILENAME"

    And I assign "300" to variable "workflow.max.polling.time"

    # To avoid any conflict with existing production data we will fast forward to next month. This month will thus be the "previous" month, and next month will be the "current" month being reported
    Given I execute below query and extract values of "MS_DATE;ME_DATE;TRD_DATE;TRD_DATE_OUTPUT;BATCH_NUMBER" into same variables
    """
    ${testdata.path}/sql/002_fetch_dates.sql
    """

    And I execute below query to "teardown existing test data"
    """
    ${testdata.path}/sql/002_tear_down.sql
    """

    And I execute below query to "insert test data"
    """
    ${testdata.path}/sql/002_create_test_data.sql
    """

    And I execute below query to "update portfolio currency"
    """
    UPDATE ft_t_wact
    SET    bkpg_curr_cde = 'SGP'
    WHERE  dw_status_num = 1
    AND    acct_sok = (SELECT acct_sok FROM ft_t_wack WHERE dw_acct_id = 'ALJPDJ');
    """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" from location "${testdata.path}"

  Scenario: TC_2: Load Transactions

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_TRN |

    Then I expect workflow is processed in DMP with success record count as "10"

  Scenario: TC_3: Refresh cross rates data and exchange rate materialised view

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedureDW/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_wfxr_cross_rates |

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_daily_month_rates |

  Scenario: TC_4: Publish netflows extract

    Given I remove below files in the host "dwh.ssh.outbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                  |
      | CONVERT_TO_EXCEL    | false                                                                                                   |
      | FILE_DIRECTORY      | ${PUBLISHING_DIRECTORY}                                                                                 |
      | PUBLISHING_FILENAME | ${PUBLISHING_FILE_NAME}.csv                                                                             |
      | THREAD_COUNT        | 1                                                                                                       |
      | SQL_ID              | SELECT DISTINCT wtrd_sok id FROM ft_v_rpt1_netflows WHERE me_date = TO_DATE('${ME_DATE}','yyyy-mon-dd') |
      | SQL_PUBLISH         | SELECT wtrd_sok id, flow_data FROM ft_v_rpt1_netflows                                                   |

    Then I expect below files to be present in the host "dwh.ssh.outbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dwh.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}.csv |

  Scenario: TC_5: Reconcile netflows extract with expected output

    Given I create input file "${EXPECTED_OUTPUT_FILENAME}" using template "002_netflows_DW_expected_output_template.csv" from location "${testdata.path}/outfiles"

    And I capture current time stamp into variable "recon.timestamp"

    And I exclude below columns from CSV file while doing reconciliations
      | Pfolio Name |

    Then I expect each record in file "${testdata.path}/outfiles/testdata/${EXPECTED_OUTPUT_FILENAME}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}.csv" and exceptions to be written to "${testdata.path}/outfiles/002_exceptions_${recon.timestamp}.csv" file

  Scenario: TC_6: Teardown test data

    Then I remove variable "workflow.max.polling.time" from memory

    Given I execute below query to "update portfolio currency"
    """
    UPDATE ft_t_wact
    SET    bkpg_curr_cde = 'JPY'
    WHERE  dw_status_num = 1
    AND    acct_sok = (SELECT acct_sok FROM ft_t_wack WHERE dw_acct_id = 'ALJPDJ');
    """

    And I execute below query to "teardown existing test data"
    """
    ${testdata.path}/sql/002_tear_down.sql
    """