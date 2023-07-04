#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH1+OCR-DMP+EOD+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3390
#TOM-3390 : R5.IN-CASH1 OCR-DMP EOD Cash Statement

@gc_interface_cash
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3390 @taiwan_cash_statement @tw_cashstatement_c_invalidData @tom_4075
Feature: Load cash statement from OCR to DMP with only Closing Balance for single portfolio and single currency
  Taiwan's custodian banks sent EOD cash statements to EIS. The statements are loaded into BRS via DMP.
  Expected Result:  If a file is received in which one or more records has incorrect/invalid data in any of the fields then Reject entire file

  Scenario: TC1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "009_EODCash_C_InvalidCCY_Template.csv" to variable "INPUT_FILENAME_INVALID_CCY_TEMPLATE"
    And I assign "009_EODCash_C_InvalidCCY.csv" to variable "INPUT_FILENAME_INVALID_CCY"
    And I assign "009_EODCash_InvalidFund_Template.csv" to variable "INPUT_FILENAME_INVALID_FUND_TEMPLATE"
    And I assign "009_EODCash_InvalidFund.csv" to variable "INPUT_FILENAME_INVALID_FUND"
    And I assign "009_EODCash_InvalidTranType_Template.csv" to variable "INPUT_FILENAME_INVALID_TRANTYPE_TEMPLATE"
    And I assign "009_EODCash_InvalidTranType.csv" to variable "INPUT_FILENAME_INVALID_TRANTYPE"
    And I assign "009_EODCash_statementdateFormat_ddmmyyyy.csv" to variable "INPUT_FILENAME_DATEFORMAT"
    And I assign "/dmp/out/brs" to variable "PUBLISHING_DIRECTORY"
    And I assign "009_EODCash_OTC_BRSFile" to variable "PUBLISHING_FILE_NAME"
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

    And I create input file "${INPUT_FILENAME_INVALID_CCY}" using template "${INPUT_FILENAME_INVALID_CCY_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${INPUT_FILENAME_INVALID_FUND}" using template "${INPUT_FILENAME_INVALID_FUND_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${INPUT_FILENAME_INVALID_TRANTYPE}" using template "${INPUT_FILENAME_INVALID_TRANTYPE_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |

  Scenario: TC2: Load cash statement file for portfolio "TT56" and currency "NTD" with invalid Currency
  Expected result: It should reject the entire file as brs will not load file

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_INVALID_CCY} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_INVALID_CCY} |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT  |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) as NTEL_ROW_COUNT FROM gs_gc.ft_t_ntel
      WHERE last_chg_trn_id IN
      (
        SELECT trn_id FROM gs_gc.ft_t_trid
        WHERE JOB_ID = '${JOB_ID}'
      )
      """
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

  Scenario: TC3: Load cash statement file for portfolio "TT565" with invalid Fund
  Expected result: It should reject the entire file as brs will not load file

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_INVALID_FUND} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                |
      | FILE_PATTERN  | ${INPUT_FILENAME_INVALID_FUND} |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT   |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "20":
      """
      SELECT count(*) as NTEL_ROW_COUNT FROM gs_gc.ft_t_ntel
      WHERE last_chg_trn_id IN
      (
        SELECT trn_id FROM gs_gc.ft_t_trid
        WHERE JOB_ID = '${JOB_ID}'
      )
      """
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC4: Load cash statement file for portfolio "TT565" with invalid trantype
  Expected result: It should reject the entire file as brs will not load file

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_INVALID_TRANTYPE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_INVALID_TRANTYPE} |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT       |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "10":
      """
      SELECT count(*) as NTEL_ROW_COUNT FROM gs_gc.ft_t_ntel
      WHERE last_chg_trn_id IN
      (
        SELECT trn_id FROM gs_gc.ft_t_trid
        WHERE JOB_ID = '${JOB_ID}'
      )
      """
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC5: Load cash statement file for portfolio "TT23" and currency "USD"  only closing balance with date format ddmmyyyy
  Expected result: It should reject the entire file as brs will not load file with different statement date format for same portfolio in same file

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_DATEFORMAT} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME_DATEFORMAT} |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as NTEL_ROW_COUNT FROM gs_gc.ft_t_ntel
      WHERE last_chg_trn_id IN
      (
        SELECT trn_id FROM gs_gc.ft_t_trid
        WHERE JOB_ID = '${JOB_ID}'
      )
      """
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
