#Current Ticket: https://jira.intranet.asia/browse/TOM-4502
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1330
#Requirement Link: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14802883

@gc_interface_cash
@dmp_regression_unittest
@02_tom_4502_brs_dmp_f11
Feature: F11-1 | File11 | BRS to DMP ITAP Cash File - Exceptions

  Below Scenarios are handled as part of this feature:
  1. Validate Exceptions in case of PORTFOLIO (ITAP FILE) is not present in DMP
  2. Validate Exceptions in case of NULL PORTFOLIO (ITAP FILE)
  3. Validate Exceptions in case of NULL INVNUM
  4. Validate Exceptions in case of NULL FUND
  5. Validate Exceptions in case of NULL INVNUM & FUND

  Scenario: TC_1: Validate Exceptions in case of FUND not present in DMP

    Given I assign "4502_ITAP_Test_File_No_Fund.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/Regression-DMP/Intraday/BRS_TO_BNP/Cash/File11-ITAP/TOM-4502" to variable "testdata.path"
    And I assign "4502_ITAP_Test_File_Portfolio_Exceptions_template.xml" to variable "PORTFOLIO_EXCEPTION_TEMPLATENAME"
    And I assign "4502_ITAP_Test_File_FUND_INV_Exceptions_template.xml" to variable "FUND_INV_EXCEPTION_TEMPLATENAME"
    And I generate value with date format "mmss" and assign to variable "TIMESTAMP1"

    When I create input file "${INPUT_FILENAME}" using template "${PORTFOLIO_EXCEPTION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | INV_CAN | ${TIMESTAMP1}0 |
      | INV_NEW | ${TIMESTAMP1}1 |
      | PNAME   | NONEXIST00     |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    And I extract new job id from jblg table into a variable "JOB_ID"

     # VERIFYING FUND DOES NOT EXIST IN DMP
    Then I expect value of column "FUND_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(ACCT_ID) AS FUND_COUNT FROM FT_T_ACID WHERE ACCT_ALT_ID = '${PNAME}' AND ACCT_ID_CTXT_TYP IN('ALTCRTSID','ESPORTCDE','CRTSID')
      """

    # VERIFYING FILE LOAD JOB IS NOT SUCCESSFUL
    Then I expect value of column "FAILED_COUNT" in the below SQL query equals to "2":
      """
      SELECT TASK_FAILED_CNT AS FAILED_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    #Validating the exception with the FUND value not present in DMP
    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.NOTFCN_ID = 26
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.CHAR_VAL_TXT LIKE '%${PNAME}% received from BRS  could not be retrieved from the AccountAlternateIdentifier%'

      """

  Scenario: TC_2: Validate Exceptions in case of NULL PORTFOLIO (ITAP FILE)
    When I create input file "${INPUT_FILENAME}" using template "${PORTFOLIO_EXCEPTION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | INV_CAN | ${TIMESTAMP1}2 |
      | INV_NEW | ${TIMESTAMP1}3 |
      | PNAME   |                |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    And I extract new job id from jblg table into a variable "JOB_ID"

     # VERIFYING FUND DOES NOT EXIST IN DMP
    Then I expect value of column "FUND_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(ACCT_ID) AS FUND_COUNT FROM FT_T_ACID WHERE ACCT_ALT_ID = '${PNAME}' AND ACCT_ID_CTXT_TYP IN('ALTCRTSID','ESPORTCDE','CRTSID')
      """

    # VERIFYING FILE LOAD JOB IS NOT SUCCESSFUL
    Then I expect value of column "FAILED_COUNT" in the below SQL query equals to "2":
      """
      SELECT TASK_FAILED_CNT AS FAILED_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    #Validating the exception with the FUND value not present in DMP
    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.NOTFCN_ID = 26
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.CHAR_VAL_TXT LIKE '%${PNAME}% received from BRS  could not be retrieved from the AccountAlternateIdentifier%'

      """

  Scenario: TC_3: Validate Exceptions in case of NULL INVNUM & FUND
    When I create input file "${INPUT_FILENAME}" using template "${FUND_INV_EXCEPTION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | NULL_FND_CAN |  |
      | NULL_INV_CAN |  |
      | NULL_FND_NEW |  |
      | NULL_INV_NEW |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    And I extract new job id from jblg table into a variable "JOB_ID"

      # VERIFYING FILE LOAD JOB IS NOT SUCCESSFUL
    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "2":
      """
      SELECT TASK_PARTIAL_CNT AS PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    #Validating the exception with the FUND value not present in DMP
    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.MSG_SEVERITY_CDE = 40
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fieldsFUNDINVNUMis not present in the input record%'

      """

  Scenario: TC_4: Validate Exceptions in case of NULL INVNUM
    When I create input file "${INPUT_FILENAME}" using template "${FUND_INV_EXCEPTION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | NULL_FND_CAN | 3100 |
      | NULL_INV_CAN |      |
      | NULL_FND_NEW | 3100 |
      | NULL_INV_NEW |      |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    And I extract new job id from jblg table into a variable "JOB_ID"

      # VERIFYING FILE LOAD JOB IS NOT SUCCESSFUL
    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "2":
      """
      SELECT TASK_PARTIAL_CNT AS PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    #Validating the exception with the FUND value not present in DMP
    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.MSG_SEVERITY_CDE = 40
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fieldsINVNUMis not present in the input record%'

      """

  Scenario: TC_5: Validate Exceptions in case of NULL FUND
    When I create input file "${INPUT_FILENAME}" using template "${FUND_INV_EXCEPTION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | NULL_FND_CAN |            |
      | NULL_INV_CAN | ${INV_CAN} |
      | NULL_FND_NEW | ${INV_NEW} |
      | NULL_INV_NEW |            |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    And I extract new job id from jblg table into a variable "JOB_ID"

      # VERIFYING FILE LOAD JOB IS NOT SUCCESSFUL
    Then I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "2":
      """
      SELECT TASK_PARTIAL_CNT AS PARTIAL_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    #Validating the exception with the FUND value not present in DMP
    Then I expect value of column "EXCEPTION_MSG_CHK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.MSG_SEVERITY_CDE = 40
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fieldsFUNDis not present in the input record%'

      """