#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH1+OCR-DMP+EOD+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3390
#TOM-3390 : R5.IN-CASH1 OCR-DMP EOD Cash Statement

@gc_interface_cash
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3390 @taiwan_cash_statement @tw_cashstatement_ot_without_closingbalance @tom_4075
Feature: Load cash statement from OCR to DMP with Opening balance, Transactions for single portfolio and single currency
  Taiwan's custodian banks sent EOD cash statements to EIS. The statements are loaded into BRS via DMP.
  Expected Result: Cash statement should not get loaded in DMP

  Scenario: TC1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "008_EODCash_OT_Without_ClosingBalance_Template.csv" to variable "INPUT_FILENAME_TEMPLATE"
    And I assign "008_EODCash_OT_Without_ClosingBalance.csv" to variable "INPUT_FILENAME"
    And I assign "/dmp/out/brs" to variable "PUBLISHING_DIRECTORY"
    And I assign "008_EODCash_OTC_BRSFile" to variable "PUBLISHING_FILE_NAME"
    And I assign "008_EODCash_OT_ExpectedOutput.csv" to variable "OUTPUT_TEMPLATE"
    And I assign "008_EODCash_OT_Output.csv" to variable "OUTPUT_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """
    And I execute below query
      """
      ${testdata.path}/sql/ClearData_CashStatement.sql
      """

    And I execute below query and extract values of "PORTFOLIO_NAME" into same variables
     """
     SELECT ACCT_ALT_ID AS PORTFOLIO_NAME FROM ft_t_acid where acct_id_ctxt_typ = 'CRTSID' AND ACCT_ALT_ID like 'TT%'  AND end_tms IS NULL  ORDER  BY 1 DESC
     """

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_1"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_FILENAME_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${OUTPUT_FILENAME}" using template "${OUTPUT_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |

  Scenario: TC2: Load cash statement file for portfolio "PRU_FM_FI_PIF-HIG" and currency "EUR" without closing balance
  Expected Result: DMP should publish the file without closing balance and user will manually update in aladdin as this file will be rejected by Aladdin

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='3'
      """
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect all records in file "${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_TC2_exceptions.csv" file
