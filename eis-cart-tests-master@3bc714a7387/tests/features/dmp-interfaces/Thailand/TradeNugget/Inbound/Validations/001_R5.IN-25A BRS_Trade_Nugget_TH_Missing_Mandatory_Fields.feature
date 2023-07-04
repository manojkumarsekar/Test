#https://jira.pruconnect.net/browse/EISDEV-6416
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND#businessRequirements-508441805
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction

@gc_interface_transactions
@dmp_regression_unittest
@eisdev_6416 @001_onmarket_validations @dmp_thailand_hiport @dmp_thailand
Feature: Load the trade nugget file where transaction file has missing mandatory fields

  This feature will test the below scenarios
  1. Load the transaction file with missing mandatory fields
  2. Verify the success,failure and partial count in jblg table
  3. Verify the exception in ntel table for each of the field

  Scenario: TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Inbound/Validations" to variable "testdata.path"

    #Transaction Files
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_Transaction_Mandatory_Field_Missing_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "001_R5.IN-25A BRS_Trade_Nugget_TH_Transaction_Mandatory_Field_Missing_Prerequisite.xml" to variable "TRANSACTION_FILE"

    #Generate Sys Date and assign to variable
    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "Mss" and assign to variable "VAR_RANDOM"

    #Load the Transaction file
  Scenario: TC 2: Load the transaction file in the trade nugget

    Given I create input file "${TRANSACTION_FILE}" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with total record count as "10"

  Scenario: TC 3: Extract variable values from run time file

    #Extract the valies from XML into Variables
    When I extract below values from the xml file "${testdata.path}/testdata/${TRANSACTION_FILE}"  with xpath or tagName at index 9 and assign to variables:
      | //TRADE/INVNUM                    | VAR_INVNUM    |
      | //TRADE/CUSIP                     | VAR_BCUSIP    |
      | //TRADE/PORTFOLIOS_PORTFOLIO_NAME | VAR_PORTFOLIO |

    #Verify the failure and success count in JBLG table
  Scenario: TC 4: Verify the success and failure count

    Then I expect workflow is processed in DMP with success record count as "0"

    And fail record count as "3"

    And partial record count as "7"

    #Verify the exception message in NTEL table
  Scenario Outline: TC 5: Verify the exception message for missing <Field>

    Then I expect value of column "EXCEPTION_COUNT" in the below SQL query equals to "1":

    """
    SELECT COUNT(*) AS EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
    AND CHAR_VAL_TXT LIKE '<Exception_Msg>'
    AND NOTFCN_STAT_TYP='OPEN'
    """

    Examples:
      | Field                 | Exception_Msg                                                                                         |
      | BCUSIP                | %Cannot process file as required fields, CUSIP is not present in the input record.                    |
      | Fund                  | %Cannot process file as required fields, FUND is not present in the input record.                     |
      | InvNum                | %Cannot process file as required fields, INVNUM is not present in the input record.                   |
      | Portfolio Name        | %Cannot process file as required fields PORTFOLIOS PORTFOLIO NAME is not present in the input record. |
      | Touch Count           | %Cannot process file as required fields, TOUCH COUNT is not present in the input record.              |
      | Tran Type 1           | %Cannot process file as required fields, TRAN TYPE1 is not present in the input record.               |
      | Trade Original Face   | %Cannot process file as required fields, TRD ORIG FACE is not present in the input record.            |
      | Trade Settlement Date | %Cannot process file as required fields, TRD SETTLE DATE is not present in the input record.          |
      | Trade Trade Date      | %Cannot process file as required fields, TRD TRADE DATE is not present in the input record.           |

   #Verify the exception message in NTEL table using notification id
  Scenario: TC 5: Verify the exception message for HiportSecID

    Given I expect an exception is captured with the following criteria
      | NOTFCN_ID | 60036 |