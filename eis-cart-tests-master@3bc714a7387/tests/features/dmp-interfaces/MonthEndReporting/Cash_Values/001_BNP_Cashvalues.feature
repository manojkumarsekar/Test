# =================================================================================
# Date            JIRA           Comments
# ============    ===========    ========
# 01/06/2020      EISDEV-6372    Intial Version
# 03/06/2020      EISDEV-6450    Use case for back-dated transactions have been added
# 23/07/2020      EISDEV-6468    Changes to report based on position date
# 25/08/2020      EISDEV-6726    Remove space from VALUATION_DATE column header
# 20/10/2020      EISDEV-6907    Transaction Type Code changes for Purchase and Sale Columns
# 20/10/2020      EISDEV-6931    First Business Day for Month of October was returning 05/10 instead of 01/10. Updated fetch dates sql to correctly fetch first business day
# Requirement https://collaborate.pruconnect.net/pages/viewpage.action?pageId=51382118#Processes--1418173114
# =================================================================================

@dw_interface_cash @dw_interface_positions @dw_interface_transactions
@dmp_dw_regression
@eisdev_6372 @eisdev_6450 @eisdev_6468 @eisdev_6726 @eisdev_6907 @eisdev_6931
Feature: 001 | Cash Values | Verify BNP Cash Values distributed to MNG

  =======================================================================================================================================================
  Below use cases will be covered as part of this test

  001 Verify Summing up for Transaction Type Code in ('CCRE', 'CCRC')
  002 Verify Summing up for Transaction Type Code in ('CLIQ', 'CLIC')
  003 Verify Summing up for Transaction Type Code in (“AFEE”, “CUFE”, “DFEE”, “MFEE”, “MFER”)
  004 NVL for CCRE , CCRC ,CLIQ,CLIC, “AFEE”, “CUFE”, “DFEE”, “MFEE”, “MFER” for Fund AGOBAB. Value for these columns should be published as 0
  005 Verify only MNG Portfolios are extracted.
  006 Verify line items based on sod-position date and month-end position date
  007 Verify sod position data is extracted in price column for all dates except month end
  008 Verify month-end position data is extracted in price column for month end
  009 Verify back dated transaction + transactions with trade date = 1st day of month are summed upto 1st business day of month - Portfolio JGQJTE
  010 Verify back dated transaction and no transactions with trade date = 1st day of month are summed upto 1st business day to month - Porfolio JGSACJ
  =======================================================================================================================================================

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: TC_1: Setup input and expected output files from templates

    #Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Cash_Values" to variable "testdata.path"
    And I assign "/dmp/out/eis/general" to variable "PUBLISHING_DIRECTORY"
    And I assign "ESI_Monthly_Cash_Values" to variable "PUBLISHING_FILE_NAME"
    And I assign "001_mc_input_BNP_TRN_template.out" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "001_mc_input_BNP_TRN.out" to variable "INPUT_FILENAME"
    And I assign "001_mc_input_BNP_POS_template.out" to variable "POS_INPUT_TEMPLATE_FILENAME"
    And I assign "001_mc_input_BNP_POS.out" to variable "POS_INPUT_FILENAME"

    And I assign "ESI_Monthly_Cash_Values_expected_output.csv" to variable "EXPECTED_OUTPUT_FILENAME"

    # To avoid any conflict with existing production data we will fast forward to next month. This month will thus be the "previous" month, and next month will be the "current" month being reported
    Given I execute below query and extract values of "MS_DATE;ME_DATE;TRD_DATE;TRD_DATE_2;TRD_DATE_3;OUTPUT_TRD_DATE;OUTPUT_TRD_DATE_2;OUTPUT_TRD_DATE_3;OUTPUT_MS_DATE;TRD_DATE_OUTPUT;FIRST_BUS_DATE;ME_DATE_OUTPUT;BATCH_NUMBER" into same variables
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

    And I execute below query to "insert test positions data"
    """
    ${testdata.path}/sql/002_gc_pos.sql
    """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" from location "${testdata.path}"
    And I create input file "${POS_INPUT_FILENAME}" using template "${POS_INPUT_TEMPLATE_FILENAME}" from location "${testdata.path}"

  Scenario: TC_2: Load Transactions

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_TRN |

    Then I expect workflow is processed in DMP with success record count as "39"

  Scenario: TC_3: Load ME Positions

    Given I process "${testdata.path}/testdata/${POS_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${POS_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS   |

    Then I expect workflow is processed in DMP with success record count as "8"

  Scenario: TC_4: Publish bnp cash flow extract

    Given I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                           |
      | CONVERT_TO_EXCEL    | false                                                                                                            |
      | FILE_DIRECTORY      | ${PUBLISHING_DIRECTORY}                                                                                          |
      | PUBLISHING_FILENAME | ${PUBLISHING_FILE_NAME}.csv                                                                                      |
      | THREAD_COUNT        | 1                                                                                                                |
      | SQL_ID              | select distinct posn_sok id from ft_v_rpt1_bnp_me_cashvalues where me_date = TO_DATE('${ME_DATE}','yyyy-mon-dd') |
      | SQL_PUBLISH         | select posn_sok id, flow_data from ft_v_rpt1_bnp_me_cashvalues                                                   |

    Then I expect below files to be present in the host "dwh.ssh.outbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dwh.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}.csv |

  Scenario: TC_5: Reconcile cashvalues extract with expected output

    Given I create input file "${EXPECTED_OUTPUT_FILENAME}" using template "ESI_Monthly_Cash_Values_Template.csv" from location "${testdata.path}/outfiles"

    And I capture current time stamp into variable "recon.timestamp"

    And I exclude below columns from CSV file while doing reconciliations
      | ESI_PUBLISH_TS |
      | BNP_PUBLISH_TS |

    Then I expect each record in file "${testdata.path}/outfiles/testdata/${EXPECTED_OUTPUT_FILENAME}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}.csv" and exceptions to be written to "${testdata.path}/outfiles/002_exceptions_${recon.timestamp}.csv" file

  Scenario: TC_6: Teardown test data

    Given I execute below query to "teardown existing test data"
    """
    ${testdata.path}/sql/002_tear_down.sql
    """