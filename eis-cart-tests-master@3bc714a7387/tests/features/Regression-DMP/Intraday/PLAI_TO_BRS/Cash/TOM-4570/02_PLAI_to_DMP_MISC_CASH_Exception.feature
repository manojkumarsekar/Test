#Ticket link : https://jira.intranet.asia/browse/TOM-4570
#Parent Ticket: https://jira.intranet.asia/browse/TOM-3500
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=45847680#Test-logicalMapping
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - Removing scenarios for exception validations with Zero or Blank Pricipal

@gc_interface_cash
@dmp_regression_unittest
@02_tom_4570_plai_dmp_misc_cash @eisdev_7170
Feature: PLAI_MISC_CASH1  | MISC CASH | PLAI to DMP MISC Cash Exception scenarios.

  Description:
  1. Loading Intraday cash files from PLAI to DMP
  2. Verifying all mandatory exceptions and invalid exceptions are thrown in case of bad data

  Scenario: Loading Intraday PLAI MISC Cash File to check exception flow

    Given I assign "tests/test-data/Regression-DMP/Intraday/PLAI_TO_BRS/Cash/TOM-4570" to variable "testdata.path"
    And I generate value with date format "ddMMYY" and assign to variable "VAR_CURRDATE"

    And I assign "PLAI_MISC_CASH_Inbound_Exceptions_${VAR_CURRDATE}.csv" to variable "RUNTIME_TESTDATAFILE3"

    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_PLAI_MISC_Cash.sql
    """

    When I create input file "${RUNTIME_TESTDATAFILE3}" using template "PLAI_MISC_CASH_Inbound_Exception_Template.csv" with below codes from location "${testdata.path}"
      | TRADE_DATE  | DateTimeFormat:dd-MMM-yy                      |
      | SETTLE_DATE | DateTimeFormat:dd-MMM-yy                      |
      | COMMENTS    | 'TEST PLAI MGMT FEE 'DateTimeFormat:dd-MMM-yy |


    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RUNTIME_TESTDATAFILE3} |


    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${RUNTIME_TESTDATAFILE3}              |
      | MESSAGE_TYPE  | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION |

    And I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Verify mandatory field missing exceptions

    Then I expect value of column "MNDTRY_EXCEPTION_ROW_COUNT" in the below SQL query equals to "4":

    """
    SELECT COUNT(*) AS MNDTRY_EXCEPTION_ROW_COUNT
    FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    WHERE TRID.JOB_ID = '${JOB_ID}'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MSG_TYP = 'ESII_MT_TAC_INTRADAY_MISC_TRANSACTION'
    AND NTEL.PARM_VAL_TXT LIKE '%Cannot process the record as required fields%'
    AND NTEL.NOTFCN_ID= '60001'
    AND NTEL.MSG_SEVERITY_CDE = '40'
    """

  Scenario: Verify invalid data handling exceptions

    Then I expect value of column "INVLD_EXCEPTION_ROW_COUNT" in the below SQL query equals to "2":

    """
    SELECT COUNT(*) AS INVLD_EXCEPTION_ROW_COUNT
    FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    WHERE TRID.JOB_ID = '${JOB_ID}'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.MSG_TYP = 'ESII_MT_TAC_INTRADAY_MISC_TRANSACTION'
    AND NTEL.CHAR_VAL_TXT LIKE 'An error occurred during translation%'
    AND NTEL.NOTFCN_ID= '15'
    AND NTEL.MSG_SEVERITY_CDE = '50'

    """