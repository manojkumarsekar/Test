#Current Ticket: https://jira.intranet.asia/browse/TOM-4502
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1330
#Requirement Link: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14802883TRD_DTE

@gc_interface_cash
@dmp_regression_unittest
@01_tom_4502_brs_dmp_f11
Feature: F11-1 | File11 | BRS to DMP ITAP Cash File load

  Below Scenarios are handled as part of this feature:
  1. Validation for mandatory fields post ITAP file load for new and cancelled trades
  2. Validation for other fields as per requirement including principle value validation
  3. Validation for principle post re-load with amended touch count

  Scenario: TC_1: Processing the ITAP test file for verification

    Given I assign "4502_ITAP_Test_File.xml" to variable "INPUT_FILENAME_1"
    And I assign "4502_ITAP_Test_File_Amended.xml" to variable "INPUT_FILENAME_2"
    And I assign "tests/test-data/Regression-DMP/Intraday/BRS_TO_BNP/Cash/File11-ITAP/TOM-4502" to variable "testdata.path"
    And I assign "4502_ITAP_Test_File_template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "4502_ITAP_Test_File_Amendment_template.xml" to variable "AMND_TEMPLATENAME"
    And I generate value with date format "mmss" and assign to variable "TIMESTAMP1"

    When I create input file "${INPUT_FILENAME_1}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | INV_CAN | ${TIMESTAMP1}0 |
      | INV_NEW | ${TIMESTAMP1}1 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_1}" with xpath "//INVNUM" at index 0 to variable "VAR_INVNUM_C"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_1}" with xpath "//INVNUM" at index 1 to variable "VAR_INVNUM_N"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_1}" with xpath "//TRD_PRINCIPAL" at index 1 to variable "VAR_TRD_PRINCIPAL_N"

  Scenario Outline: TC_2: Extract each field value from ITAP XML File to Data-Table

    Given  I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_1}" with xpath "//INVNUM[text()='${VAR_INVNUM_C}']/..//<TagName>" to variable "<VariableName>"

    Examples: Parsing each node of the input ITAP XML File
      | TagName                   | VariableName                    |
      | TRD_MODIFY_DATE           | VAR_TRD_MODIFY_TIME_C           |
      | CUSIP                     | VAR_CUSIP_C                     |
      | PORTFOLIOS_PORTFOLIO_NAME | VAR_PORTFOLIOS_PORTFOLIO_NAME_C |
      | TRD_TRADE_DATE            | VAR_TRD_TRADE_DATE_C            |
      | TRD_SETTLE_DATE           | VAR_TRD_SETTLE_DATE_C           |
      | SM_CURRENCY               | VAR_SM_CURRENCY_C               |
      | TRD_PRINCIPAL             | VAR_TRD_PRINCIPAL_C             |

  Scenario Outline: TC_3: File11 Validations for input field: <ValidationStatus> with respective transformations in DMP for 'Cancelled' Trade

    Then I expect value of column "<ValidationStatus>" in the below SQL query equals to "PASS":
    """
    <SQL>
    """
    Examples: Expecting 'Pass' for each field from ITAP XML File vs Database
      | ValidationStatus      | SQL                                                                                                                                                                                                                                                                                                                                                                    |
      | TRD_STATUS_CHECK      | SELECT CASE WHEN COUNT(X.EXEC_TRD_STAT_TYP) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_STATUS_CHECK FROM FT_T_EXST X JOIN FT_T_ETID T ON X.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}' AND X.EXEC_TRD_STAT_TYP = 'CANC'                                                                                                                          |
      | STAT_TMS_CHECK        | SELECT CASE WHEN COUNT(X.STAT_TMS) = 1 THEN 'PASS' ELSE 'FAIL' END AS STAT_TMS_CHECK FROM FT_T_EXST X JOIN FT_T_ETID T ON X.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}' AND X.STAT_TMS <= TO_DATE('${VAR_TRD_MODIFY_TIME_C}','DD/MM/YY')                                                                                                     |
      | TRN_CDE_CHECK         | SELECT CASE WHEN COUNT(R.TRN_CDE) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRN_CDE_CHECK FROM FT_T_EXTR R JOIN FT_T_ETID T ON R.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}' AND R.TRN_CDE = 'CSHALL11'                                                                                                                                             |
      | BUY_SELL_TYP_CHECK    | SELECT CASE WHEN COUNT(R.BUY_SELL_TYP) = 1 THEN 'PASS' ELSE 'FAIL' END AS BUY_SELL_TYP_CHECK FROM FT_T_EXTR R JOIN FT_T_ETID T ON R.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}' AND R.BUY_SELL_TYP IN ('B','S','')                                                                                                                           |
      | ISS_ID_CHECK          | SELECT CASE WHEN COUNT(I.ISS_ID) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_ID_CHECK FROM FT_T_ISID I JOIN FT_T_ETID T ON I.DATA_SRC_ID=T.DATA_SRC_ID WHERE I.ID_CTXT_TYP = 'BCUSIP' AND I.ISS_ID = '${VAR_CUSIP_C}' AND  T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}'                                                                                                            |
      | EXEC_TRN_ID_CHECK     | SELECT CASE WHEN COUNT(EXEC_TRN_ID) = 1 THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_ID_CHECK FROM FT_T_ETID WHERE EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND EXEC_TRN_ID = '3100${VAR_INVNUM_C}'                                                                                                                                                                                |
      | ACCT_ALT_ID_CHECK     | SELECT CASE WHEN COUNT(A.ACCT_ALT_ID ) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_ALT_ID_CHECK FROM FT_T_ACID A JOIN FT_T_EXTR X ON A.ACCT_ID=X.ACCT_ID JOIN FT_T_ETID T ON X.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE A.ACCT_ID_CTXT_TYP IN ('ESPORTCDE','ALTCRTSID','CRTSID') AND A.ACCT_ALT_ID  = '${VAR_PORTFOLIOS_PORTFOLIO_NAME_C}'  AND EXEC_TRN_ID = '3100${VAR_INVNUM_C}' |
      | TRD_DTE_CHECK         | SELECT CASE WHEN COUNT(R.TRD_DTE) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_DTE_CHECK FROM FT_T_EXTR R JOIN FT_T_ETID T ON R.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE EXEC_TRN_ID  = '3100${VAR_INVNUM_C}' AND R.TRD_DTE <= TO_DATE('${VAR_TRD_TRADE_DATE_C}','DD/MM/YY')                                                                                                          |
      | SETTLE_DTE_CHECK      | SELECT CASE WHEN COUNT(R.SETTLE_DTE) = 1 THEN 'PASS' ELSE 'FAIL' END AS SETTLE_DTE_CHECK FROM FT_T_EXTR R JOIN FT_T_ETID T ON R.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE EXEC_TRN_ID  = '3100${VAR_INVNUM_C}' AND R.SETTLE_DTE <= TO_DATE('${VAR_TRD_SETTLE_DATE_C}','DD/MM/YY')                                                                                                |
      | TRD_CURR_CDE_CHECK    | SELECT CASE WHEN COUNT(R.TRD_CURR_CDE) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_CURR_CDE_CHECK FROM FT_T_EXTR R JOIN FT_T_ETID T ON R.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE R.TRD_CURR_CDE = '${VAR_SM_CURRENCY_C}' AND T.EXEC_TRN_ID  = '3100${VAR_INVNUM_C}'                                                                                                                 |
      | NET_SETTLE_CAMT_CHECK | SELECT CASE WHEN COUNT(M.NET_SETTLE_CAMT) = 1 THEN 'PASS' ELSE 'FAIL' END AS NET_SETTLE_CAMT_CHECK FROM FT_T_ETMG M JOIN FT_T_ETID T ON M.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE M.NET_SETTLE_CAMT = '${VAR_TRD_PRINCIPAL_C}' AND T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}'                                                                                                       |

  Scenario Outline: TC_4: File11 Validations for input field: <ValidationStatus> with respective transformations in DMP for 'New' Trade

    Then I expect value of column "<ValidationStatus>" in the below SQL query equals to "PASS":
    """
    <SQL>
    """
    Examples: Expecting 'Pass' for each field from ITAP XML File vs Database
      | ValidationStatus      | SQL                                                                                                                                                                                                                                                              |
      | TRD_STATUS_CHECK      | SELECT CASE WHEN COUNT(X.EXEC_TRD_STAT_TYP) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_STATUS_CHECK FROM FT_T_EXST X JOIN FT_T_ETID T ON X.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE T.EXEC_TRN_ID = '3100${VAR_INVNUM_N}' AND X.EXEC_TRD_STAT_TYP = 'NEWM'                    |
      | NET_SETTLE_CAMT_CHECK | SELECT CASE WHEN COUNT(M.NET_SETTLE_CAMT) = 1 THEN 'PASS' ELSE 'FAIL' END AS NET_SETTLE_CAMT_CHECK FROM FT_T_ETMG M JOIN FT_T_ETID T ON M.EXEC_TRD_ID=T.EXEC_TRD_ID WHERE M.NET_SETTLE_CAMT = '${VAR_TRD_PRINCIPAL_N}' AND T.EXEC_TRN_ID = '3100${VAR_INVNUM_N}' |

  Scenario: TC_5: Processing the ITAP test file for verification (Post Override)
  #Validations for trade amendment with incremented touch-count
    When I create input file "${INPUT_FILENAME_2}" using template "${AMND_TEMPLATENAME}" with below codes from location "${testdata.path}"
      |  |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_2}" with xpath "//TRD_PRINCIPAL" at index 0 to variable "VAR_TRD_PRINCIPAL_UPD_C"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_2}" with xpath "//TRD_PRINCIPAL" at index 1 to variable "VAR_TRD_PRINCIPAL_UPD_N"

  Scenario: TC_6: File11 Validations for input field: NET_SETTLE_CAMT_CHECK with respective transformations in DMP for reloaded ITAP test file (Post Override) for NEW record

    Then I expect value of column "NET_SETTLE_CAMT_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(M.NET_SETTLE_CAMT) = 1 THEN 'PASS' ELSE 'FAIL' END AS NET_SETTLE_CAMT_CHECK
    FROM FT_T_ETMG M JOIN FT_T_ETID T
    ON M.EXEC_TRD_ID=T.EXEC_TRD_ID
    WHERE M.NET_SETTLE_CAMT = '${VAR_TRD_PRINCIPAL_UPD_N}'
    AND T.EXEC_TRN_ID = '3100${VAR_INVNUM_N}'
    """

  Scenario: TC_7: File11 Validations for input field: NET_SETTLE_CAMT_CHECK with respective transformations in DMP for reloaded ITAP test file (Post Override) for CANC record

    Then I expect value of column "NET_SETTLE_CAMT_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(M.NET_SETTLE_CAMT) = 1 THEN 'PASS' ELSE 'FAIL' END AS NET_SETTLE_CAMT_CHECK
    FROM FT_T_ETMG M JOIN FT_T_ETID T
    ON M.EXEC_TRD_ID=T.EXEC_TRD_ID
    WHERE M.NET_SETTLE_CAMT = '${VAR_TRD_PRINCIPAL_UPD_C}'
    AND T.EXEC_TRN_ID = '3100${VAR_INVNUM_C}'
    """

  # Removed Scenario per discussion: TC_7: Processing the ITAP test file for verification (Overriding with same touch count and fund values)
