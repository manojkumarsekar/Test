#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH1+OCR-DMP+EOD+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3390
#TOM-3390 : R5.IN-CASH1 OCR-DMP EOD Cash Statement

@gc_interface_cash
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3390 @taiwan_cash_statement @tw_cashstatement_c_multiccy @tom_4075
Feature: Load cash statement from OCR to DMP with only Closing Balance for single portfolio and multi currency

  Taiwan's custodian banks sent EOD cash statements to EIS. The statements are loaded into BRS via DMP.

  Scenario: TC1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "005_EODCash_C_MultiCCY_Template.csv" to variable "INPUT_FILENAME_TEMPLATE"
    And I assign "005_EODCash_C_MultiCCY.csv" to variable "INPUT_FILENAME"
    And I assign "005_EODCash_C_MultiCCY_SameDay_Template.csv" to variable "INPUT_FILENAME_SAMEDAY_TEMPLATE"
    And I assign "005_EODCash_C_MultiCCY_SameDay.csv" to variable "INPUT_FILENAME_SAMEDAY"
    And I assign "/dmp/out/brs" to variable "PUBLISHING_DIRECTORY"
    And I assign "005_EODCash_OTC_BRSFile" to variable "PUBLISHING_FILE_NAME"
    And I assign "005_EODCash_C_MultiCCY_ExpectedOutput1.csv" to variable "OUTPUT_TEMPLATE"
    And I assign "005_EODCash_C_MultiCCY_Output1.csv" to variable "OUTPUT_FILENAME"
    And I assign "005_EODCash_C_MultiCCY_ExpectedOutput2.csv" to variable "OUTPUT_SAMEDAY_TEMPLATE"
    And I assign "005_EODCash_C_MultiCCY_Output2.csv" to variable "OUTPUT_FILENAME_SAMEDAY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    And I execute below query and extract values of "PORTFOLIO_NAME" into same variables
     """
     SELECT ACCT_ALT_ID AS PORTFOLIO_NAME FROM ft_t_acid where acct_id_ctxt_typ = 'CRTSID' AND ACCT_ALT_ID like 'TT%'  AND end_tms IS NULL  ORDER  BY 1 DESC
     """

    And I execute below query
      """
      ${testdata.path}/sql/ClearData_CashStatement.sql
      """

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_1"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_FILENAME_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${INPUT_FILENAME_SAMEDAY}" using template "${INPUT_FILENAME_SAMEDAY_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${OUTPUT_FILENAME}" using template "${OUTPUT_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |
    And I create input file "${OUTPUT_FILENAME_SAMEDAY}" using template "${OUTPUT_SAMEDAY_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |

  Scenario: TC2: Load cash statement file for portfolio "TT23" and currency "AUD,USD,ZAR,CNY,TWD"  only closing balance
  Expected Result: a) Cash statement should get loaded without any issue/Exception (Check in JBLG)
  b) The published file for BRS should calculate the value for Opening balance and transactions in following order
  Opening Balance = AMOUNT field=0 , STMTDATE same as closing balance record
  and TRANTYPE=''OPENBAL" Transactions = Only one record for transaction for same portfolio and ccy will be displayed with AMOUNT=Closing Amount-Opening
  Amount, STMTDATE same as closing balance record and TRANTYPE=''BULKPOSTING' Closing Balance (As per ocr file)

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='5'
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


  Scenario: TC3: Load cash statement file for portfolio "TT23" and currency "AUD,USD,ZAR,CNY,TWD"  only closing balance and amount change to check the calculation
  Expected Result: a) Cash statement should get loaded without any issue/Exception (Check in JBLG)
  b) The published file for BRS should calculate the value for Opening balance and transactions as below
  Opening Balance =Yesterday closing balance of same portfolio and currency in AMOUNT field, STMTDATE same as closing balance record
  and TRANTYPE=''OPENBAL" Transactions = Only one record for transaction for same portfolio and ccy will be displayed with AMOUNT=Closing Amount-Opening
  Amount, STMTDATE same as closing balance record and TRANTYPE=''BULKPOSTING'

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_SAMEDAY} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME_SAMEDAY}    |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='5'
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

    Then I expect all records in file "${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME_SAMEDAY}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_TC2_exceptions.csv" file
