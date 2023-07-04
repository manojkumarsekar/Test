#Ticket link : https://jira.intranet.asia/browse/TOM-4570
#Parent Ticket: https://jira.intranet.asia/browse/TOM-3500
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=45847680#Test-logicalMapping

@gc_interface_cash
@dmp_regression_unittest
@01_tom_4570_plai_dmp_misc_cash
Feature: PLAI_MISC_CASH1  | MISC CASH | PLAI to DMP MISC Cash load and Mapping scenarios.

  Description:
  1. Loading Intraday cash files from PLAI to DMP
  2. Verifying all valid  records got processed successfully
  3. Verifying updates and new transactions are inserted, duplicate records are not overwritten in GC db based on GS logic

#  For MISC Cash transactions, the FT_T_EXTR table stores the unique identifier- TRD_ID as PORTFOLIO+TRADE DATE+ROW NUM in which the transaction appears in the incoming file
#  There are various scenarios described in this feature file, to check the update functionality due to this unique key.

  Scenario: Loading Intraday PLAI MISC Cash File to check positive flow

    Given I assign "tests/test-data/Regression-DMP/Intraday/PLAI_TO_BRS/Cash/TOM-4570" to variable "testdata.path"
    And I generate value with date format "ddMMYY" and assign to variable "VAR_CURRDATE"

    And I assign "PLAI_MISC_CASH_Inbound_New_${VAR_CURRDATE}.csv" to variable "RUNTIME_TESTDATAFILE1"

    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_PLAI_MISC_Cash.sql
    """

    When I create input file "${RUNTIME_TESTDATAFILE1}" using template "PLAI_MISC_CASH_Inbound_Template.csv" with below codes from location "${testdata.path}"
      | TRADE_DATE  | DateTimeFormat:dd-MMM-yy                      |
      | SETTLE_DATE | DateTimeFormat:dd-MMM-yy                      |
      | COMMENTS    | 'TEST PLAI MGMT FEE 'DateTimeFormat:dd-MMM-yy |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RUNTIME_TESTDATAFILE1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${RUNTIME_TESTDATAFILE1}              |
      | MESSAGE_TYPE  | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION |

  Scenario Outline: Verify MISC cash transaction with <CashDirection> are successfully loaded to relevant tables

    Given I extract below values for row <RowNum> from CSV file "${RUNTIME_TESTDATAFILE1}" in local folder "${testdata.path}/testdata" with reference to "CURRENCY" column and assign to variables:
      | PORTFOLIO   | VAR_PORTFOLIO   |
      | TRADE_DATE  | VAR_TRADE_DATE  |
      | SETTLE_DATE | VAR_SETTLE_DATE |
      | CURRENCY    | VAR_CURRENCY    |
      | COMMENTS    | VAR_COMMENTS    |
      | PRINCIPAL   | VAR_PRINCIPAL   |

    #Capturing the unique key (EXEC_TRD_ID) of cash flow transaction in FT_T_EXTR table
    And I execute below query and extract values of "EXEC_TRD_ID_ROW_<RecordNum>" into same variables
    """
    SELECT EXTR.EXEC_TRD_ID AS EXEC_TRD_ID_ROW_<RecordNum> FROM FT_T_EXTR EXTR
    JOIN FT_T_ETMG ETMG ON EXTR.EXEC_TRD_ID = ETMG.EXEC_TRD_ID
    JOIN FT_T_EXST EXST ON EXTR.EXEC_TRD_ID = EXST.EXEC_TRD_ID
    WHERE EXTR.TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','dd-MON-yy')
    AND EXTR.SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','dd-MON-yy')
    AND EXTR.SETTLE_CURR_CDE = '${VAR_CURRENCY}'
    AND EXTR.TRD_LEGEND_TXT = '${VAR_COMMENTS}'
    AND ETMG.NET_SETTLE_CAMT = '${VAR_PRINCIPAL}'
    AND EXTR.TRD_CQTY = '0' AND EXTR.TRN_CDE = 'ESIICASHTXN'
    AND EXTR.EXEC_TRN_CAT_TYP = 'MISC' AND EXTR.EXEC_TRN_CAT_SUB_TYP = 'MFEE'
    AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'
    AND EXST.STAT_TMS = TO_DATE('${VAR_CURRDATE}','DD/MM/YY')
    AND EXTR.ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('${VAR_PORTFOLIO}') GROUP BY ACCT_ID)
    AND EXTR.TRD_ID IN ('${VAR_PORTFOLIO}${VAR_TRADE_DATE}<RecordNum>')
    """

    And I expect value of column "PROCESS_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) AS PROCESS_ROW_COUNT FROM FT_T_EXTR EXTR where EXTR.EXEC_TRD_ID = '${EXEC_TRD_ID_ROW_<RecordNum>}'
    """

    #RecordNum is the sequence number as per input file excluding header
    #RowNum is the sequence number as per input file including header
    Examples:
      | CashDirection      | RowNum | RecordNum |
      | Positive cash flow | 2      | 1         |
      | Negative cash flow | 3      | 2         |

  Scenario: Verifying if PLAI MISC Cash transaction with same portfolio, principal and trade date combination in a different row creates a new transaction in GC db

    Given I extract below values for row 4 from CSV file "${RUNTIME_TESTDATAFILE1}" in local folder "${testdata.path}/testdata" with reference to "CURRENCY" column and assign to variables:
      | PORTFOLIO   | VAR_PORTFOLIO   |
      | TRADE_DATE  | VAR_TRADE_DATE  |
      | SETTLE_DATE | VAR_SETTLE_DATE |
      | CURRENCY    | VAR_CURRENCY    |
      | COMMENTS    | VAR_COMMENTS    |
      | PRINCIPAL   | VAR_PRINCIPAL   |

    #Comparing EXEC_TRD_ID of row 1 and row 4 in the file to verify if two distinct transactions are created in GC db based on the row number difference
    Then I expect value of column "EXEC_TRAN_ID_NEW" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) as EXEC_TRAN_ID_NEW FROM FT_T_EXTR EXTR
      JOIN FT_T_ETMG ETMG ON EXTR.EXEC_TRD_ID = ETMG.EXEC_TRD_ID
      JOIN FT_T_EXST EXST ON EXTR.EXEC_TRD_ID = EXST.EXEC_TRD_ID
      WHERE EXTR.TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_CURR_CDE = '${VAR_CURRENCY}'
      AND EXTR.TRD_LEGEND_TXT = '${VAR_COMMENTS}'
      AND ETMG.NET_SETTLE_CAMT = '${VAR_PRINCIPAL}'
      AND EXTR.TRD_CQTY = '0' AND EXTR.TRN_CDE = 'ESIICASHTXN'
      AND EXTR.EXEC_TRN_CAT_TYP = 'MISC' AND EXTR.EXEC_TRN_CAT_SUB_TYP = 'MFEE'
      AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.STAT_TMS = TO_DATE('${VAR_CURRDATE}','DD/MM/YY')
      AND EXTR.ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('${VAR_PORTFOLIO}') GROUP BY ACCT_ID)
      AND EXTR.EXEC_TRD_ID NOT IN '${EXEC_TRD_ID_ROW_1}'
      """

  Scenario: Loading MISC Cash file to verify Overwrite functionality based on varying principal and row numbers in the incoming file

    Given I assign "PLAI_MISC_CASH_Inbound_Update_${VAR_CURRDATE}.csv" to variable "RUNTIME_TESTDATAFILE2"

    When I create input file "${RUNTIME_TESTDATAFILE2}" using template "PLAI_MISC_CASH_Inbound_Update_Template.csv" with below codes from location "${testdata.path}"
      | TRADE_DATE  | DateTimeFormat:dd-MMM-yy                      |
      | SETTLE_DATE | DateTimeFormat:dd-MMM-yy                      |
      | COMMENTS    | 'TEST PLAI MGMT FEE 'DateTimeFormat:dd-MMM-yy |
      | RANDMNUM    | DateTimeFormat:ddHHMHMs'.089'                 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RUNTIME_TESTDATAFILE2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${RUNTIME_TESTDATAFILE2}              |
      | MESSAGE_TYPE  | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION |

  Scenario: Verifying if the NET_SETTLE_CAMT field is updated when the principal amount field is different for an existing transaction

    Given I extract below values for row 2 from CSV file "${RUNTIME_TESTDATAFILE2}" in local folder "${testdata.path}/testdata" with reference to "CURRENCY" column and assign to variables:
      | PORTFOLIO   | VAR_PORTFOLIO   |
      | TRADE_DATE  | VAR_TRADE_DATE  |
      | SETTLE_DATE | VAR_SETTLE_DATE |
      | CURRENCY    | VAR_CURRENCY    |
      | COMMENTS    | VAR_COMMENTS    |
      | PRINCIPAL   | VAR_PRINCIPAL   |

    Then I expect value of column "EXEC_TRAN_ID_UPDATE1" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) as EXEC_TRAN_ID_UPDATE1 FROM FT_T_EXTR EXTR
      JOIN FT_T_ETMG ETMG ON EXTR.EXEC_TRD_ID = ETMG.EXEC_TRD_ID
      JOIN FT_T_EXST EXST ON EXTR.EXEC_TRD_ID = EXST.EXEC_TRD_ID
      WHERE EXTR.TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_CURR_CDE = '${VAR_CURRENCY}'
      AND EXTR.TRD_LEGEND_TXT = '${VAR_COMMENTS}'
      AND ETMG.NET_SETTLE_CAMT = '${VAR_PRINCIPAL}'
      AND EXTR.TRD_CQTY = '0' AND EXTR.TRN_CDE = 'ESIICASHTXN'
      AND EXTR.EXEC_TRN_CAT_TYP = 'MISC' AND EXTR.EXEC_TRN_CAT_SUB_TYP = 'MFEE'
      AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.STAT_TMS = TO_DATE('${VAR_CURRDATE}','DD/MM/YY')
      AND EXTR.ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('${VAR_PORTFOLIO}') GROUP BY ACCT_ID)
      AND EXTR.EXEC_TRD_ID IN '${EXEC_TRD_ID_ROW_1}' -- EXEC_TRD_ID_ROW_1 is captured when New file got loaded
      """

  Scenario: Verifying if the NET_SETTLE_CAMT is updated when the principal amount field is same for an existing transaction

    Given I extract below values for row 3 from CSV file "${RUNTIME_TESTDATAFILE2}" in local folder "${testdata.path}/testdata" with reference to "CURRENCY" column and assign to variables:
      | PORTFOLIO   | VAR_PORTFOLIO   |
      | TRADE_DATE  | VAR_TRADE_DATE  |
      | SETTLE_DATE | VAR_SETTLE_DATE |
      | CURRENCY    | VAR_CURRENCY    |
      | COMMENTS    | VAR_COMMENTS    |
      | PRINCIPAL   | VAR_PRINCIPAL   |


    And I expect value of column "EXEC_TRAN_ID_NO_UPDATE" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) as EXEC_TRAN_ID_NO_UPDATE FROM FT_T_EXTR EXTR
      JOIN FT_T_ETMG ETMG ON EXTR.EXEC_TRD_ID = ETMG.EXEC_TRD_ID
      JOIN FT_T_EXST EXST ON EXTR.EXEC_TRD_ID = EXST.EXEC_TRD_ID
      WHERE EXTR.TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_CURR_CDE = '${VAR_CURRENCY}'
      AND EXTR.TRD_LEGEND_TXT = '${VAR_COMMENTS}'
      AND ETMG.NET_SETTLE_CAMT = '${VAR_PRINCIPAL}'
      AND EXTR.TRD_CQTY = '0' AND EXTR.TRN_CDE = 'ESIICASHTXN'
      AND EXTR.EXEC_TRN_CAT_TYP = 'MISC' AND EXTR.EXEC_TRN_CAT_SUB_TYP = 'MFEE'
      AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.STAT_TMS = TO_DATE('${VAR_CURRDATE}','DD/MM/YY')
      AND EXTR.ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('${VAR_PORTFOLIO}') GROUP BY ACCT_ID)
      AND EXTR.EXEC_TRD_ID IN '${EXEC_TRD_ID_ROW_2}' -- EXEC_TRD_ID_ROW_2 captured when New file got loaded
      """

  Scenario: Verify if multiple records are created in the Database if all parameters of a file are same for transactions coming up in different row numbers

    Given I extract below values for row 4 from CSV file "${RUNTIME_TESTDATAFILE2}" in local folder "${testdata.path}/testdata" with reference to "CURRENCY" column and assign to variables:
      | PORTFOLIO   | VAR_PORTFOLIO   |
      | TRADE_DATE  | VAR_TRADE_DATE  |
      | SETTLE_DATE | VAR_SETTLE_DATE |
      | CURRENCY    | VAR_CURRENCY    |
      | COMMENTS    | VAR_COMMENTS    |
      | PRINCIPAL   | VAR_PRINCIPAL   |

    Then I expect value of column "DUPLICATE_TXNS_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(1) as DUPLICATE_TXNS_COUNT FROM FT_T_EXTR EXTR
      JOIN FT_T_ETMG ETMG ON EXTR.EXEC_TRD_ID = ETMG.EXEC_TRD_ID
      JOIN FT_T_EXST EXST ON EXTR.EXEC_TRD_ID = EXST.EXEC_TRD_ID
      WHERE EXTR.TRD_DTE = TO_DATE('${VAR_TRADE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_DTE = TO_DATE('${VAR_SETTLE_DATE}','dd-MON-yy')
      AND EXTR.SETTLE_CURR_CDE = '${VAR_CURRENCY}'
      AND EXTR.TRD_LEGEND_TXT = '${VAR_COMMENTS}'
      AND ETMG.NET_SETTLE_CAMT = '${VAR_PRINCIPAL}'
      AND EXTR.TRD_CQTY = '0' AND EXTR.TRN_CDE = 'ESIICASHTXN'
      AND EXTR.EXEC_TRN_CAT_TYP = 'MISC' AND EXTR.EXEC_TRN_CAT_SUB_TYP = 'MFEE'
      AND EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.STAT_TMS = TO_DATE('${VAR_CURRDATE}','DD/MM/YY')
      AND EXTR.ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID IN ('${VAR_PORTFOLIO}') GROUP BY ACCT_ID)
      AND EXTR.TRD_ID LIKE ('${VAR_PORTFOLIO}${VAR_TRADE_DATE}%')
      """
