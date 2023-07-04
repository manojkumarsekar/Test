#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CAS1+FAS-%3EDMP+Intraday+New+Cash+Transactions
#https://jira.intranet.asia/browse/TOM-3368
#TOM-3368 : New inbound created for Taiwan New Cash


@tom_3847 @tom_3368 @tom_3943 @dmp_interfaces @taiwan_dmp_interfaces @taiwan_newcash
Feature: Loading Taiwan FAS new cash into DMP

  Taiwan's transfer agent cash subscriptions and redemptions are entered into a Taiwan in-house system called FAS. FAS will publish these
  cash transactions to BRS, via DMP. DMP is required to translate FAS share class codes to BRS portfolio codes.

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/cleardown.sql
    """

  Scenario: TC_2: Setup new account in DMP with CRTS ID

    #As the current portfolio template does not have TWFASID column to set up the code , for the purpose of this test case we are inserting the codes via a sql

    Given I assign "TOM-3686-PortTemplate-TW-attributes.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |


  Scenario: TC_3: Clear the data as a Prerequisite

    Given I assign "TW_newcash_inbound.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"

     # Clear data
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_R5_IN_CAS1_Intraday_New_Cash.sql
    """

  Scenario: TC_4: Load New Cash File

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_TW_FAS_NEW_CASH |


  Scenario: TC_5: Data Verifications

    # Validation 1: New Cash - Total Successfully Processed Records => 3 records should be created in EXTR
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
        """
        ${testdata.path}/sql/Processed_Row_Count_R5_IN_CAS1.sql
        """

    # Validation 2: NewCash- New => 3 records should be created in extr/etmg/etid with correct mapping for columns EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO,ESTIMATED
    Then I expect value of column "EXTR_NEW_CASH_COUNT" in the below SQL query equals to "3":
        """
        ${testdata.path}/sql/Data_Verification_New_Cash_R5_IN_CAS1.sql
        """


    # Validation 3: New Cash - Mandatory Field Missing Records => 1 record should be created in NTEL
    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "1":
        """
        ${testdata.path}/sql/Missing_Fields_Data_Exception_R5_IN_CAS1.sql
        """