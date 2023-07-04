#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844973
#https://jira.intranet.asia/browse/TOM-3392
#TOM-3392 : New inbound created for Indonesia new cash
#TOM-3595 : Trade date and Settle date format changed from dd/mm/yyyy to dd-mmm-yy
#TOM-3654 : ESID Misc/New cash interface changes
#TOM-4043: Modified ID-TA to BNP for Indo New cash
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - Removing scenarios for exception validations with Zero or Blank Amount

@gc_interface_cash
@dmp_regression_unittest
@tom_4043 @tom_3392 @1005_dmp_new_cash_ta_to_dmp @eisdev_7170
Feature: Inbound new cash from TA/Client to DMP Interface Testing (R4.IN-ID.4A New Cash from TA/Client to DMP)

  Load new cash file with below records (details below), all containing EXTERN_NEWCASH_ID1, PORTFOLIO, AMOUNT, CURRENCY, CASH_TYPE, SETTLE_DATE, TRADE_DATE as mandatory fields
  and CANCEL, COMMENTS as optional field

  "EXTERN_NEWCASH_ID1","PORTFOLIO","AMOUNT","CURRENCY","CASH_TYPE","SETTLE_DATE","TRADE_DATE","CANCEL","COMMENTS"
  "123","NDSICF","2300000","IDR","CASHIN","20180628","20180625","N","NewCash for NDSICF"
  "456","ADPSEF","456789.67","IDR","CASHOUT","20180628","20180622","N",""
  "789","NDSICF","150000","IDR","CASHIN","20180621","20180611","","NewCash for NDSICF"
  "889","NDSICF","0","IDR","CASHIN","20180621","20180611","Y","NewCash for NDSICF"
  "989","NDSICF","150000","IDR","CASHIN","20180621","20180611","Y","CancelCash for NDSICF"
  "","","","","","","","Y","NA"


  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "R4_IN_ID_4A_SCB_Test_File_For_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3392" to variable "testdata.path"

    Given I execute below query to "Clear data"
    """
    ${testdata.path}/sql/ClearData_R4_IN_ID_4A_PLAI_SCB_New_Cash.sql
    """

  Scenario: TC_2: Load New Cash File

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                           |
      | FILE_PATTERN  | ${INPUT_FILENAME}                         |
      | MESSAGE_TYPE  | ESII_MT_TAC_SCB_INTRADAY_CASH_TRANSACTION |

  Scenario: TC_3: Data Verifications

    # Validation 1: New Cash - Total Successfully Processed Records => 3 records should be created in EXTR
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "4":
        """
        ${testdata.path}/sql/R4_IN_ID_4A_PLAI_SCB_Processed_Row_Count.sql
        """

    # Validation 2: NewCash- New => 2 records should be created in extr/exst/etmg/etid with correct mapping for columns EXTERN_NEWCASH_ID1, PORTFOLIO, AMOUNT, CURRENCY, CASH_TYPE, SETTLE_DATE, TRADE_DATE, CANCEL, COMMENTS
    Then I expect value of column "EXTR_NEW_CASH_COUNT" in the below SQL query equals to "2":
        """
        ${testdata.path}/sql/R4_IN_ID_4A_PLAI_SCB_Data_Verification_New_Cash.sql
        """

    # Validation 3: NewCash- New/Cancel => 1 record should be created in extr/exst/etmg/etid with correct mapping for columns EXTERN_NEWCASH_ID1, PORTFOLIO, AMOUNT, CURRENCY, CASH_TYPE, SETTLE_DATE, TRADE_DATE, CANCEL, COMMENTS
    Then I expect value of column "EXTR_CANCEL_CASH_COUNT" in the below SQL query equals to "1":
        """
        ${testdata.path}/sql/R4_IN_ID_4A_PLAI_SCB_Data_Verification_Cancel_Cash.sql
        """
