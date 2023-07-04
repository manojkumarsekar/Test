#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844973
#https://jira.intranet.asia/browse/TOM-3500
#TOM-3500 : New inbound created for Indonesia misc cash
#TOM-3595 : Trade date and Settle date format changed from dd/mm/yyyy to dd-mmm-yy
#TOM-3654 : ESID Misc/New cash interface changes
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - changing scenarios for exception validations with Zero or Blank Principal

@gc_interface_cash
@dmp_regression_unittest
@tom_3500 @tom_3595 @tom_3654 @misc_cash_inbound @eisdev_7170
Feature: Inbound misc cash from PLAI to DMP Interface Testing (R4.IN-CAS11 MISC Cash from PLAI Indonesia to DMP)

  Load misc cash file with below records (details below), all containing CURRENCY,PORTFOLIO,TRADE_DATE,SETTLE_DATE,PRINCIPAL as mandatory fields and COMMENTS as optional field

  CURRENCY,PORTFOLIO,TRADE_DATE,SETTLE_DATE,PRINCIPAL,COMMENTS
  IDR,NDSICF,25-Jun-18,26-Jun-18,"-3,555.25",TOM-3500 TICKET AUTOMATED TESTING
  IDR,ADPSEF,27-Jun-18,28-Jun-18,-1070.69,TOM-3500 TICKET AUTOMATED TESTING
  IDR,ADPSEF,22-Jun-18,21-Jun-18,0,TOM-3500 TICKET AUTOMATED TESTING
  IDR,NDSICF,29-Jun-18,30-Jun-18,"4,180,687.63",TOM-3500 TICKET AUTOMATED TESTING
  IDR,ADPSEF,21-Jun-18,20-Jun-18,175.42,TOM-3500 TICKET AUTOMATED TESTING
  ,,,,30000.30,TOM-3500 TICKET AUTOMATED TESTING

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "R4_IN_CAS11_Test_File_For_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3500" to variable "testdata.path"

    # Clear data
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_R4_IN_CAS11_MISC_Cash.sql
    """

  Scenario: TC_2: Load misc cash File

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME}                     |
      | MESSAGE_TYPE  | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: TC_3: Data Verifications

    # Validation 1: misc cash - Total Successfully Processed Records => 3 records should be created in EXTR
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "4":
        """
        ${testdata.path}/sql/R4_IN_CAS11_Processed_Row_Count.sql
        """

    # Validation 2: misc cash - Mandatory Field Missing Records => 1 record should be created in NTEL
    Then I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "1":
        """
        ${testdata.path}/sql/R4_IN_CAS11_Missing_Fields_Data_Exception.sql
        """
