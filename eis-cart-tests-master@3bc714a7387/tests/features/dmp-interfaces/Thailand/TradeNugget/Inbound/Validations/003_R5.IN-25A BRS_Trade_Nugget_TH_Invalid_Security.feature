#https://jira.pruconnect.net/browse/EISDEV-6416
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND#businessRequirements-508441805
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction

@gc_interface_transactions
@dmp_regression_unittest
@eisdev_6416 @003_onmarket_validations @dmp_thailand_hiport @dmp_thailand
Feature: Load the trade nugget file for a Security not present in DMP

  This feature will test the below scenarios
  1. Load the transaction file where security is not present in DMP
  2. Verify the success, failure and partial count in jblg table
  3. Verify the exception in ntel table

  Scenario: TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Inbound/Validations" to variable "testdata.path"

    #Transaction Files
    And I assign "003_R5.IN-25A BRS_Trade_Nugget_TH_Transaction_Invalid_Sec_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "003_R5.IN-25A BRS_Trade_Nugget_TH_Transaction_Invalid_Sec_Prerequisite.xml" to variable "TRANSACTION_FILE"

    #Extract Portfolio Code into a variable
    And I extract value from the xml file "${testdata.path}/template/${TRANSACTION_TEMPLATE}" with tagName "CUSIP" to variable "SECURITY_ID"


    #Generate Sys Date and assign to variable
    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "HHss" and assign to variable "VAR_RANDOM"

    #End date the security and portfolio used in Txn file
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${SECURITY_ID}'"

    #Load the Transaction file
  Scenario: TC 2: Load the transaction file in the trade nugget

    Given I create input file "${TRANSACTION_FILE}" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with total record count as "1"

    #Verify the failure and success count in JBLG table
  Scenario: TC 3: Verify the success and failure count

    Then I expect workflow is processed in DMP with success record count as "0"

    And fail record count as "1"

    #Verify the exception message in NTEL table
  Scenario: TC 4: Verify the exception message

    Then I expect value of column "EXCEPTION_COUNT" in the below SQL query equals to "1":

    """
    SELECT COUNT(*) AS EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
    AND CHAR_VAL_TXT LIKE 'The Issue for ''IDCTXTTYP - ${SECURITY_ID}'' provided by BRS is not present in the IssueIdentifier.'
    AND NOTFCN_STAT_TYP='OPEN'
    """

  Scenario: TC5: Revert the end date update of security

    Then I execute below query to "Revert end date update of security"
    """
    UPDATE FT_T_ISID
    SET END_TMS=NULL
    WHERE INSTR_ID IN
      (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${SECURITY_ID}')
    AND TRUNC(END_TMS)=TRUNC(SYSDATE);

    commit;
    """