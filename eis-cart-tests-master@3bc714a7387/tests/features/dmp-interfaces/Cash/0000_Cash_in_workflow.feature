#This is a sample test
@cash_in
Feature: Inbound Intraday Cash Transactions Interface Testing (R3.IN.CAS1 BNP to DMP)

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound.

  Scenario: Process BNP Intraday Cash Transactions to DMP (CAS1)

    Given I assign "ESIINTRADAY_TRN_NEWCASH_NEW.out" to variable "INPUT_FILENAME"
    And I assign "ESIINTRADAY_TRN_NEWCASH_NEW_Template.out" to variable "INPUT_TEMPLATENAME"
    And I assign "tests/test-data/dmp-interfaces/R3_IN_CAS1_BNP_TO_DMP" to variable "testdata.path"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | DYNAMIC_CODE | DateTimeFormat:HmsS |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER               |
      | FILE_PATTERN  | ESIINTRADAY*.out                     |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

    #|ColumnName|Variable|
    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ACCT_ID               | VAR_ACCT_ID               |
      | BNP_SOURCE_TRAN_EV_ID | VAR_BNP_SOURCE_TRAN_EV_ID |
      | INSTR_ID              | VAR_INSTR_ID              |
      | BNP_SOURCE_TRAN_ID    | VAR_BNP_SOURCE_TRAN_ID    |
      | CANCEL_IND            | VAR_CANCEL_IND            |
      | BNP_CASH_IMPACT_CODE  | VAR_BNP_CASH_IMPACT_CODE  |
      | NET_SETT_AMT_L        | VAR_NET_SETT_AMT_L        |
      | NOTES                 | VAR_NOTES                 |
      | SETT_CCY              | VAR_SETT_CCY              |
      | SETT_DATE             | VAR_SETT_DATE             |
      | TRADE_DATE            | VAR_TRADE_DATE            |
      | TRAN_TYPE_CODE        | VAR_TRAN_TYPE_CODE        |

    Given I assign "${testdata.path}/queries/CASH" to variable "SQL_QUERIES_DIR"

    Then I expect value of column in the below SQL query equals to "PASS"
      | EXEC_TRN_ID_CHECK              | ${SQL_QUERIES_DIR}/EXEC_TRN_ID_CHECK.sql              |
      | EXEC_TRN_ID_WITH_TRAN_ID_CHECK | ${SQL_QUERIES_DIR}/EXEC_TRN_ID_WITH_TRAN_ID_CHECK.sql |
      | EXEC_TRD_STAT_TYP_CHECK        | ${SQL_QUERIES_DIR}/EXEC_TRD_STAT_TYP_CHECK.sql        |
      | EXEC_TRN_CL_TYP_CHECK          | ${SQL_QUERIES_DIR}/EXEC_TRN_CL_TYP_CHECK.sql          |
      | NET_SETTLE_CAMT_CHECK          | ${SQL_QUERIES_DIR}/NET_SETTLE_CAMT_CHECK.sql          |
      | TRD_LEGEND_TXT_CHECK           | ${SQL_QUERIES_DIR}/TRD_LEGEND_TXT_CHECK.sql           |
      | SETTLE_CURR_CDE_CHECK          | ${SQL_QUERIES_DIR}/SETTLE_CURR_CDE_CHECK.sql          |
      | SETTLE_DTE_CHECK               | ${SQL_QUERIES_DIR}/SETTLE_DTE_CHECK.sql               |
      | TRD_DTE_CHECK                  | ${SQL_QUERIES_DIR}/TRD_DTE_CHECK.sql                  |
      | EXEC_TRN_CAT_SUB_TYP_CHECK     | ${SQL_QUERIES_DIR}/EXEC_TRN_CAT_SUB_TYP_CHECK.sql     |
      | EXEC_TRN_CAT_TYP_CHECK         | ${SQL_QUERIES_DIR}/EXEC_TRN_CAT_TYP_CHECK.sql         |
      | TRN_CDE_CHECK                  | ${SQL_QUERIES_DIR}/TRN_CDE_CHECK.sql                  |
      | TRD_CQTY_CHECK                 | ${SQL_QUERIES_DIR}/TRD_CQTY_CHECK.sql                 |
      | ACCT_ID_CHECK                  | ${SQL_QUERIES_DIR}/ACCT_ID_CHECK.sql                  |
      | INSTR_ID_CHECK                 | ${SQL_QUERIES_DIR}/INSTR_ID_CHECK.sql                 |

